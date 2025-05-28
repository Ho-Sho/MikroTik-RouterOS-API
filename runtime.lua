-- ** Debug Print **--
DebugTx=false
DebugRx=false
DebugFunc=false
DebugPrint=Properties["Debug Print"].Value
-- A function to determine common print statement scenarios for troubleshooting
function SetupDebugPrint()
  if     DebugPrint=="Tx/Rx"    then DebugTx,DebugRx=true,true
  elseif DebugPrint=="Tx"       then DebugTx=true
  elseif DebugPrint=="Rx"       then DebugRx=true
  elseif DebugPrint=="Function" then DebugFunc=true
  elseif DebugPrint=="All"      then DebugTx,DebugRx,DebugFunc=true,true,true
  end
end
SetupDebugPrint()

-- Variables
local status = Controls["Status"]
status.Value = 5
local port = Properties["Connection Type"].Value == "TCP" and 8728 or 8729 -- 8729
local sshport = 22
local state = "init"
local nextTagId = 0
local tagCallbacks = {}
local tagRepliesAccum = {}
local initLogin = false
local hasInitVisibility = false
local buffer = "" -- rx buffer
local interfacesName, defaultName = {},{}
local polltimer = Timer.New()
-- Create TcpSocket
local sock = Properties["Connection Type"].Value == "TCP" and TcpSocket.New() or TcpSocket.NewTls() -- Tls({ VerifyPeer = false })
print("Connection Tyep: "..Properties["Connection Type"].Value)
sock.ReadTimeout = 0
sock.WriteTimeout = 0
sock.ReconnectTimeout = 5
-- Constants for reply types
local REPLY_TYPES = { DONE = "!done", TRAP = "!trap", RE = "!re", EMPTY = "!empty", FATAL = "!fatal" }
-- Set Commands table
local COMMANDS = {
  INTERFACE = "/interface/ethernet/print", POE = "/interface/ethernet/poe/print", ALL = "/interface/getall"
}
-- mapping define
local INTERFACE_MAPPING = {
  ["Interface"]            = "name", -- Port # → Interface
  ["Comment"]              = { attr = "comment", formatter = function(v) if v == "" or v == nil then return "" else return v end end, type = "String"},
  ["ReceivedByte"]         = { attr = "rx-bytes", formatter = function(v) return formatByte(v) end },
  ["ReceivedUnicast"]      = { attr = "rx-unicast", formatter = function(v) return formatCast(v) end },
  ["ReceivedMulticast"]    = { attr = "rx-multicast", formatter = function(v) return formatCast(v) end },
  ["ReceivedBroadcast"]    = { attr = "rx-broadcast", formatter = function(v) return formatCast(v) end },
  ["ReceivedError"]        = { attr = "rx-error-events", formatter = function(v) return formatCast(v) end },
  ["TransmittedByte"]      = { attr = "tx-bytes", formatter = function(v) return formatByte(v) end },
  ["TransmittedUnicast"]   = { attr = "tx-unicast", formatter = function(v) return formatCast(v) end },
  ["TransmittedMulticast"] = { attr = "tx-multicast", formatter = function(v) return formatCast(v) end },
  ["TransmittedBroadcast"] = { attr = "tx-broadcast", formatter = function(v) return formatCast(v) end },
  ["TransmittedDropped"]   = { attr = "tx-drop", formatter = function(v) return formatCast(v) end },
  -- ["DeviceMAC"]            = { attr = "mac-address", formatter = function(v) if v == "" or v == nil then return "" else return v end end, type = "String"},
  ["Running"]              = { attr = "running", formatter = function(v) return v == "true" and true or false end, type = "Boolean" },
  ["Enable/Disable Port"]  = { attr = "disabled", formatter = function(v) return v == "false" and true or false end, type = "Boolean" },
  ["PoeOut"]               = { attr = "poe-out", type = "String" },
  ["PoeVoltage"]           = { attr = "poe-voltage", formatter = function(v) return v or "0" end, type = "String" }, -- Assuming voltage is okay as string
  -- ["PoeStatus"] = { attr = "poe-out", formatter = function(v) return v == "powered-on" or v == "auto-on" or false end, type = "Boolean" },
  ["PoeMode"]              = { attr = "poe-out", formatter = function(v) return v or "N/A" end, type = "String" },
  --["Enable/Disable PoE"] = { attr = "poe-out", formatter = function(v) return v == "powered-on" or v == "auto-on" or false end, type = "Boolean" }
}
local IsInvisible_MAPPING = {
  "Interface", "Comment", "ReceivedByte", "ReceivedUnicast", "ReceivedMulticast", "ReceivedBroadcast","ReceivedError",
  "TransmittedByte", "TransmittedUnicast", "TransmittedMulticast", "TransmittedBroadcast","DeviceMAC",
  "TransmittedDropped", "LinkSpeed", "Mac", "Running", "Enable/Disable Port",
  "PoeOut", "PoeDraw", "PoeStatus", "PoeMode","PoeVoltage", "Enable/Disable PoE",
  "PoeOutStatus", "PoeOutVoltage", "PoeOutCurrent", "PoeOutPower",
}
local IsInvisible_PoE_MAPPING = {
  "PoeStatus","PoeMode","PoeVoltage","Enable/Disable PoE","PoeOutStatus","PoeOutVoltage","PoeOutCurrent","PoeOutPower",
}

Controls["SSHUsername"].String = "Every connection requires input"
Controls["SSHPassword"].String = "Every connection requires input"
-- Setup function
function Setup()
  address = Controls["IPAddress"].String == "" and "Invalid IP Address" or Controls["IPAddress"].String
  Controls["IPAddress"].String = address
  user = Controls["APIUsername"].String
  pass = Controls["APIPassword"].String
  sshuser = Controls["SSHUsername"].String
  sshpass = Controls["RealSSHPass"].String
end

sock.ReadTimeout = 0
sock.WriteTimeout = 0
sock.ReconnectTimeout = 5

-- Utility functions
function parseWord(word)
  local _, equalsPos = string.find(word, '=')
  if not equalsPos then return "type", word end
  return word:sub(1, equalsPos - 1), word:sub(equalsPos + 1)
end

function encodeLength(len)
  local char = string.char
  if len < 0x80 then
    return char(len)
  elseif len < 0x4000 then
    return char(bit.bor(bit.rshift(len, 8), 0x80)) .. char(bit.band(len, 0xFF))
  elseif len < 0x200000 then
    return char(bit.bor(bit.rshift(len, 16), 0xC0)) ..
          char(bit.band(bit.rshift(len, 8), 0xFF)) .. char(bit.band(len, 0xFF))
  elseif len < 0x10000000 then
    return char(bit.bor(bit.rshift(len, 24), 0xE0)) ..
          char(bit.band(bit.rshift(len, 16), 0xFF)) ..
          char(bit.band(bit.rshift(len, 8), 0xFF)) .. char(bit.band(len, 0xFF))
  else
    return '\xF0' .. char(bit.band(bit.rshift(len, 24), 0xFF)) ..
          char(bit.band(bit.rshift(len, 16), 0xFF)) ..
          char(bit.band(bit.rshift(len, 8), 0xFF)) .. char(bit.band(len, 0xFF))
  end
end

function encodeWord(word) return encodeLength(string.len(word)) .. word end
local MAX_TAG = 10000
function nextTag() nextTagId = (nextTagId % MAX_TAG) + 1 return "Tag" .. nextTagId end

--------------------------------------------
-- Send functions
--------------------------------------------
function sendSentence(words, callback)
  local message = ""
  for _, word in ipairs(words) do message = message .. encodeWord(word) end
  -- Add tag if callback provided and no tag exists
  if callback then
    local hasTag = false
    for _, word in ipairs(words) do
      if word:sub(1, 5) == '.tag=' then hasTag = true; break end
    end
    if not hasTag then
      local tag = nextTag()
      message = message .. encodeWord('.tag=' .. tag)
      tagCallbacks[tag] = callback
    end
  end
  message = message .. string.char(0)
  if sock.IsConnected then
    sock:Write(message)
    if DebugTx then print("Sending: " .. table.concat(words, " ")) end
  end
end

-- Unified data extraction function for all response handlers
function extractReplies(replies)
  local data = {}
  local hasErr, errMsg = false, nil
  for _, reply in ipairs(replies) do
    if reply.type == REPLY_TYPES.RE then
      local item = {}
      -- Iterate through the raw words of the reply sentence
      for _, word in ipairs(reply.raw) do
        -- Try to parse words like =key=value
        local key, value = word:match("^=([^=]+)=(.*)$")
        -- Add the key/value to the item table UNLESS it's the .tag
        if key and key ~= ".tag" then
          item[key] = value
        elseif word:match("^;;;") then
          item["comment"] = word:sub(4) -- Handle comments
        end
      end
      -- Add the populated item to the data list if it's not empty
      if next(item) then table.insert(data, item) end
    elseif reply.type == REPLY_TYPES.TRAP then
      -- Handle errors
      hasErr, errMsg = true, reply.parsed["=message"] or "Unknown error"
      break -- Stop processing replies for this tag if a trap occurs
    end
  end

  return data, hasErr, errMsg
end

function executeCommand(cmd, callback)
  local words = {}
  for word in string.gmatch(cmd, "%S+") do table.insert(words, word) end
  local wrappedCallback
  if callback then
    wrappedCallback = function(replies)
      local data, hasErr, errMsg = extractReplies(replies)
      callback(data, hasErr, errMsg, replies)
    end
  end
  sendSentence(words, wrappedCallback)
end
--------------------------------------------
-- UI update function (now using the unified data extraction)
--------------------------------------------
function sortPort(data)
  table.sort(data, function(a, b)
    local nameA, nameB = a["default-name"], b["default-name"]
    -- Determine type priority
    local function portType(n)
      if n:find("ether") then return 1 end
      if n:find("sfp") then   return 2 end
      return 3
    end
    local ta, tb = portType(nameA), portType(nameB)
    if ta ~= tb then return ta < tb end
    -- Fallback: numeric comparison of trailing digits
    local na = tonumber(nameA:match("%d+$")) or math.huge
    local nb = tonumber(nameB:match("%d+$")) or math.huge
    if na ~= nb then return na < nb end
    -- Last fallback: lexicographical
    return nameA < nameB
  end)
end

function updateUI(command, mapping, isIndex)
  isIndex = isIndex or false
  executeCommand(command, function(data, hasErr, errMsg)
    if hasErr then if DebugTx then print("Error executing command '" .. command .. "':", errMsg) return end end
    sortPort(data)
    -- Populate interface list if needed
    if command == "/interface/ethernet/print" then
      local ifaceNames = {}
      for _, entry in ipairs(data) do table.insert(ifaceNames, entry.name) end
      Controls.InterfaceToCore.Choices = ifaceNames
    end
    local items = isIndex and data or {data[1] or {}}
    for index, info in ipairs(items) do
      for ctrlName, mapInfo in pairs(mapping) do
        local attr = type(mapInfo) == "table" and mapInfo.attr or mapInfo
        local formatter = type(mapInfo) == "table" and mapInfo.formatter or function(v) return v or "N/A" end
        local mapType = type(mapInfo) == "table" and mapInfo.type or "String"
        local value = formatter(info[attr])
        local ctrl = Controls[ctrlName]
        if ctrl then
          if isIndex and type(ctrl) == "table" and ctrl[index] then
            if mapType == "Boolean" then ctrl[index].Boolean = value
            else ctrl[index].String = value
            end
          elseif not isIndex then
            if mapType == "Boolean" then ctrl.Boolean = value
            else ctrl.String = value
            end
          end
        end
      end
    end
  end)
end
--------------------------------------------
-- Buffer processing functions
--------------------------------------------
function readLenFromBuffer(pos)
  if pos > #buffer then return nil, pos end
  local lenByte = string.byte(buffer:sub(pos, pos))
  local len, bytesRead = nil, 1
  if lenByte < 0x80 then
    len = lenByte
  elseif lenByte < 0xC0 then
    if pos + 1 > #buffer then return nil, pos end
    len = ((lenByte & 0x7F) << 8) | string.byte(buffer, pos + 1)
    bytesRead = 2
  elseif lenByte < 0xE0 then
    if pos + 2 > #buffer then return nil, pos end
    len = ((lenByte & 0x3F) << 16) | (string.byte(buffer, pos + 1) << 8) |
          string.byte(buffer, pos + 2)
    bytesRead = 3
  elseif lenByte < 0xF0 then
    if pos + 3 > #buffer then return nil, pos end
    len = ((lenByte & 0x1F) << 24) | (string.byte(buffer, pos + 1) << 16) |
          (string.byte(buffer, pos + 2) << 8) | string.byte(buffer, pos + 3)
    bytesRead = 4
  elseif lenByte == 0xF0 then
    if pos + 4 > #buffer then return nil, pos end
    len = (string.byte(buffer, pos + 1) << 24) | (string.byte(buffer, pos + 2) << 16) |
          (string.byte(buffer, pos + 3) << 8) | string.byte(buffer, pos + 4)
    bytesRead = 5
  else
    if DebugRx then print("Warning: Unknown length byte: " .. lenByte)
    return nil, pos + 1 end
  end
  return len, pos + bytesRead
end

function processBuffer()
  local pos = 1
  while pos <= #buffer do
    local sentence = {}
    local parsed = {}
    local startPos = pos

    while true do
      local length, newPos = readLenFromBuffer(pos)
      if not length then buffer = buffer:sub(startPos) return end
      pos = newPos

      if length > 0 then
        if pos + length - 1 > #buffer then buffer = buffer:sub(startPos) return end
        local word = buffer:sub(pos, pos + length - 1)
        pos = pos + length
        table.insert(sentence, word)
        local attr, value = parseWord(word)
        parsed[attr] = value
      else break end
    end

    if #sentence > 0 then
      local replyType = parsed.type or "unknown"
      local typeLabels = {[REPLY_TYPES.RE] = "[DATA] ", [REPLY_TYPES.DONE] = "[DONE] ", [REPLY_TYPES.TRAP] = "[ERROR] ", [REPLY_TYPES.EMPTY] = "[EMPTY] ", [REPLY_TYPES.FATAL] = "[FATAL] ",}
      if DebugRx then print("\n" .. (typeLabels[replyType] or "[UNKNOWN] ") .. table.concat(sentence, "\n")) end
      local reply = { raw = sentence, parsed = parsed, type = replyType }
      local tag = parsed['.tag']
      if tag then
        if not tagRepliesAccum[tag] then tagRepliesAccum[tag] = {} end
        table.insert(tagRepliesAccum[tag], reply)
      end
      if replyType == REPLY_TYPES.DONE or replyType == REPLY_TYPES.TRAP or replyType == REPLY_TYPES.FATAL then
        if tag and tagCallbacks[tag] then
          local callback = tagCallbacks[tag]
          callback(tagRepliesAccum[tag])
          tagRepliesAccum[tag] = nil
          tagCallbacks[tag] = nil
        end
      end
    end
  end
  buffer = ""
end
--------------------------------------------
-- Log Functions
--------------------------------------------
function getLogEntry()
  Controls.LogMsg.Choices = {}
  executeCommand("/log/print", function(data, hasErr, errMsg)
    local logs = {}
    Controls.LogMsg.Choices = {}
    Controls.LogMsg.String = ""
    if hasErr then
      if DebugFunc then print("Error fetching logs:", errMsg) end
      Controls.LogMsg.String = "Error fetching logs: " .. (errMsg or "Unknown error")
      return
    end
    for index, logEntry in ipairs(data) do
      local time = logEntry.time or "N/A"
      local topics = logEntry.topics or "N/A"
      local message = logEntry.message or "N/A"
      local critical = topics:match('critical') and "\a" .. topics or topics
      local displayString = string.format("[No.%d] %s [%s] %s", index-1, time, topics, message)
      local entry = {Text = displayString}
      if topics:match('critical') then entry.Color = "red"
      elseif topics:match('error') then entry.Color = "red"
      elseif topics:match('warning') then entry.Color = "blue"
      end
      table.insert(logs, entry)
    end
    Controls.LogMsg.Choices = logs
    print("Successfully loaded " .. #logs .. " log entries and set to Choices.")
  end)
end
--------------------------------------------
-- Interface Visible Functions // include LinkSpeed, PoE Status
--------------------------------------------
function poeInterfaceVisible(index, visible)
  for _, iface in ipairs(IsInvisible_PoE_MAPPING) do
    Controls[iface][index].IsInvisible = visible
  end
end

function getInterfaceVisible()
  executeCommand("/interface/ethernet/poe/print =.proplist=name,default-name", function(poeData, poeErr)
    if poeErr then return end
    for _, item in ipairs(poeData) do
      if not item["default-name"] then item["default-name"] = item.name end
    end

    sortPort(poeData)
    local poePorts = {}
    for _, item in ipairs(poeData) do table.insert(poePorts, item.name) end

    executeCommand("/interface/ethernet/print =.proplist=name,default-name", function(ifData, ifErr)
      if ifErr then return end

      for _, item in ipairs(ifData) do
        if not item["default-name"] then item["default-name"] = item.name end
      end
      sortPort(ifData)

      if not hasInitVisibility then
        local maxCount = #Controls.Interface
        for i = 1, maxCount do
          local invisible = (i > #ifData)
          for _, ctrlName in ipairs(IsInvisible_MAPPING) do
            if Controls[ctrlName] and Controls[ctrlName][i] then
              Controls[ctrlName][i].IsInvisible   = invisible
              Controls.PortLabel[i].IsInvisible    = invisible
              Controls.PortLabel[i].String         = i
            end
          end
        end
        hasInitVisibility = true
      end

      for i, iface in ipairs(ifData) do
        executeCommand("/interface/ethernet/monitor =numbers="..iface.name.." =once=", function(linkRows, linkErr)
          if not linkErr and linkRows[1] then
            Controls.LinkSpeed[i].String = (linkRows[1].status=="link-ok" and linkRows[1].rate) or "no-link"
          end
        end)

        local isPoe = false
        for _, nm in ipairs(poePorts) do
          if nm == iface.name then isPoe = true; break end
        end

        if isPoe then
          executeCommand("/interface/ethernet/poe/monitor =numbers="..iface.name.." =once=", function(poeRows, poeErr)
            if not poeErr and poeRows[1] then
              local p = poeRows[1]
              Controls.PoeStatus[i].Boolean          = (p["poe-out-status"]=="powered-on")
              Controls.PoeOutStatus[i].String        = p["poe-out-status"] or "N/A"
              Controls.PoeOutVoltage[i].String       = p["poe-out-voltage"] and (p["poe-out-voltage"].." V") or "N/A"
              Controls.PoeOutCurrent[i].String       = p["poe-out-current"] and (p["poe-out-current"].." mA") or "N/A"
              Controls.PoeOutPower[i].String         = p["poe-out-power"] and (p["poe-out-power"].." W") or "N/A"
              Controls["Enable/Disable PoE"][i].Boolean = Controls.PoeStatus[i].Boolean
            end
          end)
        else
          poeInterfaceVisible(i, true)
        end
      end
    end)
  end)
end
--------------------------------------------
-- Formatting Functions
--------------------------------------------
-- Utility function to format uptime string from MikroTik
function formatDuration(uptime)
  if not uptime then return "N/A" end
  local units = {["w"] = "w", ["d"] = "d", ["h"] = "h", ["m"] = "m", ["s"] = "s", ["ms"] = "ms"} -- Added ms
  local result = {}
  -- Updated pattern to correctly capture numbers and units, including 'ms'
  for number_str, unit in string.gmatch(uptime, "(%d+)([a-z]+)") do
    local number = tonumber(number_str)
    if units[unit] and number and number > 0 then -- Ensure number is valid and > 0
      table.insert(result, number .. units[unit])
    end
  end
  return table.concat(result, " ")
end
-- Utility function to format byte counts
function formatByte(byte)
  local bytes = tonumber(byte)
  if not bytes or bytes < 0 then return "N/A" end
  local units = {"", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"}
  local i = 1
  local size = bytes
  while size >= 1024 and i < #units do
    size = size / 1024
    i = i + 1
  end
  -- Format to one or two decimal places depending on size
  if size < 10 then return string.format("%.2f %s", size, units[i])
  else return string.format("%.1f %s", size, units[i])
  end
end
-- Utility function to format large numbers with thousands separators
function formatCast(number)
  local num_str = tostring(tonumber(number))
  if num_str == "nil" or num_str == "nan" then return "N/A" end -- Handle non-numeric or NaN input
  local len = #num_str
  local formatted = ""
  local count = 0
  -- Iterate from the end of the string
  for i = len, 1, -1 do
    formatted = num_str:sub(i, i) .. formatted
    count = count + 1
    if count % 3 == 0 and i > 1 then
      formatted = "," .. formatted -- Prepend separator (use "." for some locales if needed)
    end
  end
  return formatted
end
--------------------------------------------
-- Socket Event handlers
--------------------------------------------
sock.Connected = function()
  print("Connected to MikroTik")
  state = "login"
  polltimer:Start(tonumber(Properties["Poll Rate(sec)"].Value) ) -- Properties["Poll Rate(sec)"] must 1-600 sec
  executeCommand("/login =name=" .. user .. " =password=" .. pass, function(data, hasErr, errMsg)
    if not hasErr then
      status.Value = 0
      status.String = "Authentication successful!"
      print("Authentication successful!")
      state = "ready"

      executeCommand("/interface/ethernet/print =.proplist=name,default-name", function(data, hasErr, errMsg)
        if not hasErr then
          sortPort(data)
          interfacesName, defaultName = {}, {}
          for _, item in ipairs(data) do
            table.insert(interfacesName, item.name)
            table.insert(defaultName, item["default-name"])
          end
          Controls.InterfaceToCore.Choices = interfacesName -- CorePort table
        end
      end)
      if not initLogin then
        updateUI("/system/identity/print =.proplist=name", { SystemName = "name" })
        -- Updated mapping for system resource to use formatDuration for Uptime
        updateUI("/system/resource/print =.proplist=uptime,version", {
          Uptime = { attr = "uptime", formatter = function(v) return formatDuration(v) end },
          FirmwareVersion = "version",
          BoardName = "board-name"
        })
        updateUI("/system/license/print =.proplist=software-id,nlevel", { SoftwareID = "software-id", nLevel = "nlevel" })
        updateUI("/system/routerboard/print =.proplist=model,serial-number", { Model = "model", SerialNumber = "serial-number", FirmwareType = "firmware-type", FactoryFirmwareVersion = "factory-firmware" })
        updateUI("/interface/ethernet/print", INTERFACE_MAPPING, true) -- All Status
        getInterfaceVisible()
        initLogin = true
      end
    else
      status.Value = 2
      status.String = "Authentication failed"
      print("Authentication failed")
    end
  end)
end

sock.Data = function()
  buffer = buffer .. sock:Read(sock.BufferLength)
  processBuffer()
end
sock.Error = function(_, err)
  print("Socket error:", err)
  initLogin, state, buffer = false, "init", ""
  status.Value = 3
  status.String = "Socket error: " .. err
  polltimer:Stop()
end
sock.Closed = function()
  print("Socket closed. Reconnecting in 5 seconds...")
  initLogin, state, buffer = false, "init", ""
  status.Value = 4
  status.String = "Disconnected. Reconnecting..."
  polltimer:Stop()
end

--------------------------------------------
-- Control EventHandlers
--------------------------------------------
Controls["IPAddress"].EventHandler   = function() Setup() Connect() end
Controls["APIUsername"].EventHandler = function() Setup() Connect() end
Controls["APIPassword"].EventHandler = function() Setup() Connect() end
Controls["GetLog"].EventHandler      = function() getLogEntry() end
Controls["LogClear"].EventHandler    = function() Controls.LogMsg.Choices = {} end
Controls["SSHUsername"].EventHandler = function() Setup() end

Controls["SSHPassword"].EventHandler = function()
  local passInput = Controls["SSHPassword"].String
  Controls["RealSSHPass"].String = passInput
  Setup()
  Controls["SSHPassword"].String = Controls["SSHPassword"].String ~= "" and Controls["SSHPassword"].String:gsub(".", "*") or Controls["SSHPassword"].String
end
-- Function to update visibility of InterfaceToCore related controls (per-interface action buttons/controls)
function updateInterfaceToCoreUI()
  local selectedPort = Controls.InterfaceToCore.String
  local selectedIndex = 0 -- Initialize to 0 to indicate no match found yet
  local corePortChoices = Controls.InterfaceToCore.Choices
  local maxifCount = #Controls["Interface"]
  -- Find the 1-based index in the UI list corresponding to the selected port string
  for i, choice in ipairs(corePortChoices) do
    if choice == selectedPort then selectedIndex = i break end
  end
  for i = 1, maxifCount do
    local isSelectedPortRow = (i == selectedIndex and selectedIndex > 0)
    for _, ctrlName in ipairs({"Enable/Disable Port","Enable/Disable PoE"}) do
      if Controls[ctrlName] and Controls[ctrlName][i] then
        Controls[ctrlName][i].IsDisabled = isSelectedPortRow
      end
    end
  end
end
updateInterfaceToCoreUI()

Controls.InterfaceToCore.EventHandler = function() updateInterfaceToCoreUI() end
Controls.Reboot.EventHandler = function() executeCommand("/system/reboot") status.Value = 5 status.String = "Rebooting..." end
-- PoE Enable/Disable
for i, ctrl in ipairs(Controls["Enable/Disable PoE"]) do
  ctrl.EventHandler = function()
    local ifaceName = Controls["Interface"][i].String
    local poeMode = ctrl.Boolean and "auto-on" or "off"
    local cmd = '/interface/ethernet/poe/set =numbers=' .. ifaceName .. ' =poe-out=' .. poeMode .. ''
    executeCommand(cmd, function(data, hasErr, errMsg)
      if not hasErr then getInterfaceVisible() end
    end)
  end
end
-- Port Enable/Disable
for i, ctrl in ipairs(Controls["Enable/Disable Port"]) do
  ctrl.EventHandler = function()
    local ifaceName = Controls["Interface"][i].String
    local disabledVal = ctrl.Boolean and "false" or "true"
    local cmd = '/interface/ethernet/set =numbers="' .. ifaceName .. '" =disabled=' .. disabledVal
    executeCommand(cmd, function(data, hasErr, errMsg)
      if not hasErr then getInterfaceVisible() end
    end)
  end
end
-- Comment
for i, ctrl in ipairs(Controls["Comment"]) do
  ctrl.EventHandler = function()
    local comment = Controls["Comment"][i].String
    local cmd = '/interface/ethernet/set =.id=' .. defaultName[i] .. '" =comment=' .. comment
    executeCommand(cmd, function(data, hasErr, errMsg)
      if not hasErr then updateUI("/interface/ethernet/print", INTERFACE_MAPPING, true) end
    end)
  end
end
--------------------------------------------
-- Connection functions
--------------------------------------------
function Connect()
  if sock.IsConnected then sock:Disconnect() end
  buffer = ""
  sock:Connect(address, port)
  status.Value = 5
  status.String = "Connecting to MikroTik..."
  print("Connecting to MikroTik " .. address .. ":" .. port)
end

function Disconnect()
  if sock.IsConnected then
    sock:Close()
    print("Disconnected from MikroTik")
    polltimer:Stop()
  end
  buffer = ""
  status.Value = 4
  status.String = "Disconnected"
end
--------------------------------------------
-- Auto-connect on startup
--------------------------------------------
Setup()
Connect()
--------------------------------------------
-- PollingTimer function
--------------------------------------------
polltimer.EventHandler = function()
  if sock.IsConnected then
    updateUI("/interface/ethernet/print", INTERFACE_MAPPING, true)
    updateUI("/system/resource/print =.proplist=uptime", {
      Uptime = { attr = "uptime", formatter = function(v) return formatDuration(v) end } }
    )
    executeCommand("/interface/bridge/host/print =.proplist=interface,mac-address,local", function(hosts, err, msg)
      if err then
        print("Error fetching bridge hosts: " .. (msg or "unknown"))
      else
        for idx, ifName in ipairs(interfacesName) do
          local foundMac = ""
          for _, host in ipairs(hosts) do
            if host.interface == ifName
              and host["mac-address"]
              and host["local"] == "false"
            then
              foundMac = host["mac-address"]
              break
            end
          end
          if Controls.DeviceMAC and Controls.DeviceMAC[idx] then
            Controls.DeviceMAC[idx].String = foundMac
          end
        end
      end
      getInterfaceVisible()
    end)
  else
    polltimer:Stop()
  end
end
--------------------------------------------
-- SSH-connect for CLI
--------------------------------------------
local ssh = Ssh.New()
ssh.ReadTimeout = 0
ssh.WriteTimeout = 0
ssh.ReconnectTimeout = 5
ssh.IsInteractive = false -- Use Connect with credentials

local sshTimer = Timer.New() -- Inactivity timeout timer
local setTimeout = Controls["SSHTimeOut"].Value -- Configured timeout value (seconds)
local timeoutCount = 0 -- Current countdown value (seconds)

-- Handle connection status and log messages
function connectionStatus(isConnected, msg)
  Controls.SSHConnected.Boolean = isConnected
  local timestamp = os.date("%Y-%m-%dT%H:%M:%S")
  print(msg)
  Controls.SSHOutput.String = Controls.SSHOutput.String .. "\n" .. timestamp .. " " .. msg
  -- Stop timer on disconnect
  if isConnected == false then stopSshTimer() end
end

-- Stop timeout timer and reset countdown
function stopSshTimer()
  sshTimer:Stop()
  timeoutCount = 0
  print("SSH inactivity timeout timer stopped.")
  Controls["SSHTimeOutDisplay"].String = ""
end

--------------------------------------------
-- SSH socket callbacks
--------------------------------------------
-- Called when SSH is connected and authenticated
ssh.Connected = function()
  connectionStatus(true, "SSH connected.")
  -- Start timer if timeout is configured
  if setTimeout > 0 then
    timeoutCount = setTimeout
    sshTimer:Start(1) -- 1-second interval
    print("SSH inactivity timeout timer started: " .. timeoutCount .. "s.")
    Controls["SSHTimeOutDisplay"].String = timeoutCount
  else
    print("SSH inactivity timeout disabled.")
  end
end
-- Called when data is received from SSH server
ssh.Data = function()
  local line = ssh:ReadLine(TcpSocket.EOL.Any)
  while line do
    local timestamp = os.date("%Y-%m-%dT%H:%M:%S")
    local cleanedLine = string.gsub(line, "^%s*", "")
    Controls.SSHOutput.String = Controls.SSHOutput.String .. "\n" .. timestamp .. " " .. cleanedLine
    print("SSH Data: " .. line) -- Debug
    line = ssh:ReadLine(TcpSocket.EOL.Any)
  end
end

ssh.Reconnect = function() print("SSH reconnect attempt...") end
ssh.Closed = function() connectionStatus(false, "SSH closed.") end
ssh.Error = function(s, err) connectionStatus(false, "SSH Error: " .. err) end
ssh.Timeout = function() connectionStatus(false, "SSH connection timeout.") end
ssh.LoginFailed = function() connectionStatus(false, "SSH Login Failed.") end

-- SSH Inactivity Timer EventHandler
sshTimer.EventHandler = function()
  if ssh.IsConnected then
    timeoutCount = timeoutCount - 1
    if Controls["SSHTimeOutDisplay"] then Controls["SSHTimeOutDisplay"].String = timeoutCount end
      print("SSH countdown: " .. timeoutCount) -- Debug
    if timeoutCount <= 0 then
      print("SSH connection timed out due to inactivity.")
      ssh:Disconnect()
      Controls["SSHUsername"].String, Controls["SSHPassword"].String,Controls["SSHInput"].String = "","",""
      stopSshTimer() -- Ensure stopped immediately
    else
      sshTimer:Start(1) -- Restart for next tick
    end
  else
    stopSshTimer() -- Stop if connection lost while timer running
  end
end

-- SSHConnect button pressed
Controls.SSHConnect.EventHandler = function()
  Controls.SSHTimeOutDisplay.String = "Start"
  Setup()
  -- Connect only if disconnected
  if not ssh.IsConnected then
    -- Log attempt
    Controls.SSHOutput.String = Controls.SSHOutput.String .. "\n" .. os.date("%Y-%m-%dT%H:%M:%S") .. " Connecting SSH to " .. address .. "..."
    print("Attempting SSH connection to " .. address .. " as user " .. sshuser)
    -- Connect with credentials (requires 4 args)
    ssh:Connect(address, sshport, sshuser, sshpass)
  else
    print("SSH: Already connected.")
    Controls.SSHOutput.String = Controls.SSHOutput.String .. "\n" .. os.date("%Y-%m-%dTH:%M:%S") .. " SSH: Already connected."
  end
end

-- SSHDisconnect button pressed
Controls.SSHDisconnect.EventHandler = function()
  Controls.SSHConnected.Boolean = false
  if ssh.IsConnected then
    print("Disconnecting SSH...")
    ssh:Disconnect()
    Controls["SSHUsername"].String, Controls["SSHPassword"].String,Controls["SSHInput"].String = "","",""
  end
  stopSshTimer() -- Ensure timer stops on button press
end

-- SSHSend button or Enter key pressed
Controls.SSHSend.EventHandler = function()
  if ssh.IsConnected then
    local cmd = Controls.SSHInput.String
    if cmd == "" then if DebugTx then print("SSH: Cannot send empty command.") return end end
    local commandToSend = cmd .. "\n"
    local timestamp = os.date("%Y-%m-%dT%H:%M:%S")
    if DebugTx then print("Sending SSH command: " .. string.gsub(commandToSend, "\n", "\\n")) end
    ssh:Write(commandToSend)
    Controls.SSHOutput.String = Controls.SSHOutput.String .. "\n" .. timestamp .. " Send >> " .. cmd
    -- Reset inactivity timeout on activity
    if setTimeout > 0 then
      timeoutCount = setTimeout; sshTimer:Start(1)
      print("SSH timeout reset by send activity: " .. timeoutCount .. "s.")
      Controls["SSHTimeOutDisplay"].String = timeoutCount
    end
    Controls["SSHInput"].String = ""
  end
end

-- SSHClear output button pressed
Controls.SSHClear.EventHandler = function()
  Controls.SSHOutput.String = ""
  print("SSH Output cleared.")
end

-- SSHTimeOut value changed
Controls.SSHTimeOut.EventHandler = function()
  setTimeout = Controls["SSHTimeOut"].Value or 0 -- Read new value
  if setTimeout > 0 then
    if DebugFunc then print("SSH timeout set to: " .. setTimeout .. "s.") end
    if ssh.IsConnected then
      timeoutCount = setTimeout; sshTimer:Start(1) -- Apply & restart if connected
      if DebugFunc then print("SSH timeout timer updated & started.") end
      if Controls["SSHTimeOutDisplay"] then Controls["SSHTimeOutDisplay"].String = timeoutCount end
    end
  else -- Timeout disabled (0)
    if DebugRx then print("SSH timeout disabled.") end
    stopSshTimer() -- Stop timer
  end
end
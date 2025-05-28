local pageIndex   = props["page_index"].Value
local CurrentPage = PageNames[pageIndex]
local maxIf       = tonumber(props["Total Interfaces"].Value) or 0
local perPage     = 16
local totalPages  = math.ceil(maxIf / perPage)
local firstIntPg  = 2
local lastIntPg   = firstIntPg + totalPages - 1
local eventPg     = lastIntPg + 1
local sshPg       = eventPg + (props["Enable SSH Terminal"].Value and 1 or 0)
local Colors = {
  Black = {0,0,0}, White = {255,255,255}, Red = {255,0,0}, Blue = {16,16,255}, LightBlue = {141,207,244}, Gray = {105,105,105}, LightGray = {194,194,194}, HGray = {153,153,153}, OffGray = {124,124,124},
  LightYellow = {254,248,134}, Orange = {245,186,92}, BtnGray = {51,51,51}, Background = {230,230,230}, OnlineGreen = {34,178,76}, White0 = {255,255,255,0}, Black0 = {0,0,0,0},
}
local zOerders = {back=-100, zero=0, layer10=10, layer20=20, labels=100, ctrl=200, front=1000}
local labels = {size={130,18}, size2={100,20}, size3={205,20}}
local clabels = {size={185,18}, size2={112,16}}
local btns = {size={50,20}, size2={40,20}}
local leds = {size={20,20}}

local made_logo = "--[[ #encode "made_logo.svg" ]]"

if pageIndex == 1 then
  -- Setup
  table.insert(graphics,{Type = "Svg", Image = made_logo, Position = {23, 12}, Size = {294,38}, ZOrder = zOerders.front, })
  local dLabels = {
    text = {"IP Address","API Username","API Password","Core Port Number","System Name","Model","Serial Number","Firmware Version","Uptime"},
    pos = {{10,97},{10,117},{10,137},{10,157},{10,216},{10,236},{10,256},{10,276},{10,296},}
  }
  for i=1, #dLabels.text do
    table.insert(graphics,{Type = "Text",Text = dLabels.text[i],Position = dLabels.pos[i],Color = Colors.Black, Size = labels.size, FontSize = 12, Font ="Roboto", HTextAlign = "Right", ZOrder = zOerders.labels})
  end
  table.insert(graphics,{Type = "Text", Text = "Connection Setup", Position = {5,67}, Color = Colors.Black, Size = {200,22}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Left", ZOrder = zOerders.labels})
  table.insert(graphics,{Type = "Text", Text = "Device Information", Position = {5,186}, Color = Colors.Black, Size = {200,22}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Left", ZOrder = zOerders.labels})
  table.insert(graphics,{Type = "Text", Text = "Connection Status", Position = {5,326}, Color = Colors.Black, Size = {200,22}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Left", ZOrder = zOerders.labels})
  table.insert(graphics,{Type = "Text", Text = "Version ".. PluginInfo.Version, Position = {260,388}, Color = Colors.Black, Size = {76,8}, FontSize = 9, Font ="Roboto", HTextAlign = "Right", ZOrder = zOerders.labels})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.White, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {340,404}, ZOrder = zOerders.back,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {340,62}, ZOrder = zOerders.zero,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {4,89}, Size = {332,93}, ZOrder = zOerders.zero,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {4,208}, Size = {332,114}, ZOrder = zOerders.zero,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {4,348}, Size = {332,48}, ZOrder = zOerders.zero,})
  layout["IPAddress"] = {PrettyName = "Setup~IP Address", Style = "TextBox", Position = {145,97}, Size = clabels.size, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["APIUsername"] = {PrettyName = "Setup~API User Name", Style = "TextBox", Position = {145,117}, Size = clabels.size, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["APIPassword"] = {PrettyName = "Setup~API Password", Style = "TextBox", Position = {145,137}, Size = clabels.size, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["InterfaceToCore"] = {PrettyName = "Setup~Interface To Core", Style = "ComboBox", Position = {145,157}, Size = clabels.size, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }

  layout["SystemName"] = {PrettyName = "Device Information~System Name", Style = "TextBox", Position = {145,216}, Size = clabels.size, FontSize = 12, Color = Colors.LightGray, StrokeWidth = 1, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl }
  layout["Model"] = {PrettyName = "Device Information~Model", Style = "TextBox", Position = {145,236}, Size = clabels.size, FontSize = 12, Color = Colors.LightGray, StrokeWidth = 1, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl }
  layout["SerialNumber"] = {PrettyName = "Device Information~Serial Number", Style = "TextBox", Position = {145,256}, Size = clabels.size, FontSize = 12, Color = Colors.LightGray, StrokeWidth = 1, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl }
  layout["FirmwareVersion"] = {PrettyName = "Device Information~Firmware Version", Style = "TextBox", Position = {145,276}, Size = clabels.size, FontSize = 12, Color = Colors.LightGray, StrokeWidth = 1, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl }
  layout["Uptime"] = {PrettyName = "Device Information~Uptime", Style = "TextBox", Position = {145,296}, Size = clabels.size, FontSize = 12, Color = Colors.LightGray, StrokeWidth = 1, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl }
  layout["Status"] = {PrettyName = "Connection Status~Status", Style = "TextBox", Position = {9,356}, Size = {321,32}, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl }
  layout["Reboot"] = {PrettyName = "Connection Status~Reboot", Style = "Button", ButtonStyle = "Trigger", Position = {280,326}, Size = btns.size, Color = Colors.White, UnlinkOffColor = true, OffColor = {242,137,174}, CornerRadius = 2, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, Legend = "Reboot", ZOrder = zOerders.ctrl }

elseif pageIndex >= firstIntPg and pageIndex <= lastIntPg then
  local blabels = {
    text = {"Port","En/Disable","Interface","Comment","Running","Link Speed","En/Disable","Mode","State"},
    pos = {{10,95},{10,115},{10,135},{10,155},{10,175},{10,195},{10,235},{10,255},{10,275},}
  }
  for i=1, #blabels.text do
    table.insert(graphics,{Type = "Text",Text = blabels.text[i],Position = blabels.pos[i],Color = Colors.Black, Size = labels.size2, FontSize = 12, Font ="Roboto", HTextAlign = "Right", ZOrder = zOerders.labels})
  end
  if props["Port Information"].Value == "Basic+PoE" or props["Port Information"].Value == "Basic+PoE+Packets" then
    local elabels = {
      text = {"En/Disable","Mode","State","Out Status","Out Power","Out Voltage","Out Ampere"},
      pos = {{10,235},{10,255},{10,275},{10,295},{10,315},{10,335},{10,355},}
    }
    for i=1, #elabels.text do
      table.insert(graphics,{Type = "Text",Text = elabels.text[i],Position = elabels.pos[i],Color = Colors.Black, Size = labels.size2, FontSize = 12, Font ="Roboto", HTextAlign = "Right", ZOrder = zOerders.labels})
    end
  end
  if props["Port Information"].Value == "Basic+PoE+Packets" then
    local vlabels = {
      text = {"Bytes","Unicast Pkts","Multicast Pkts","Broadcast Pkts","Error Event",
      "Bytes","Unicast Pkts","Multicast Pkts","Broadcast Pkts","Dropped Pkts", "Device's MAC"},
      pos = {{10,395},{10,415},{10,435},{10,455},{10,475},
      {10,515},{10,535},{10,555},{10,575},{10,595},{10,620},}
    }
    for i=1, #vlabels.text do
      table.insert(graphics,{Type = "Text",Text = vlabels.text[i],Position = vlabels.pos[i],Color = Colors.Black, Size = labels.size2, FontSize = 12, Font ="Roboto", HTextAlign = "Right", ZOrder = zOerders.labels})
    end
  end
  local i        = pageIndex - firstIntPg + 1
  local startIf  = (i - 1) * perPage + 1
  local endIf    = math.min(i * perPage, maxIf)
  local PageName = string.format("Interfaces %d-%d", startIf, endIf)
  local maxwide = 1720
  local numInterfacesOnPage = endIf - startIf + 1
  local minport = 2
  function calcWidth(baseWidth)
    local calculated = baseWidth + math.max(0, numInterfacesOnPage - minport) * 100
    local finalWidth = math.min(calculated, maxwide)
    return finalWidth
  end
  function calcLogoWidth(baseWidth)
    local calculated = baseWidth + math.max(0, numInterfacesOnPage - minport) * 100
    local finalWidth = math.min(calculated, calcWidth(195)/2 -30 )
    return finalWidth
  end

  local interfaceBoxWidth = calcWidth(195) or 195
  -- Interface Header
  table.insert(graphics,{Type = "Header", Text = PageName, Position = {110,60}, Size = {interfaceBoxWidth, 30}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Center", Color = Colors.Black, ZOrder = zOerders.labels,})
  -- PoE Header
  table.insert(graphics,{Type = "Header", Text = "PoE", Position = {110,215}, Size = {interfaceBoxWidth, 20}, FontSize = 12, HTextAlign = "Center", Color = Colors.Black, ZOrder = zOerders.labels,})
  if props["Port Information"].Value=="Basic+PoE+Packets" then
    -- Receive Header
    table.insert(graphics,{Type = "Header", Text = "Receive", Position = {110,375}, Size = {interfaceBoxWidth, 20}, FontSize = 12, HTextAlign = "Center", Color = Colors.Black, ZOrder = zOerders.labels,})
    -- Transmit Header
    table.insert(graphics,{Type = "Header", Text = "Transmit", Position = {110,495}, Size = {interfaceBoxWidth, 20}, FontSize = 12, HTextAlign = "Center", Color = Colors.Black, ZOrder = zOerders.labels,})
  end
  local logoPos = calcLogoWidth(10) or 10
  table.insert(graphics,{Type = "Svg", Image = made_logo, Position = {logoPos, 12}, Size = {294,38}, ZOrder = zOerders.front, })
  local groupBoxWidth = calcWidth(315) or 315
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {groupBoxWidth, 60}, ZOrder = zOerders.back,})
  local groupGrayWidth = calcWidth(305) or 305
  local groupGrayHeight = props["Port Information"].Value=="Basic+PoE" and 285 or props["Port Information"].Value=="Basic+PoE+Packets" and 550 or 215 -- 530
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {5,90}, Size = {groupGrayWidth, groupGrayHeight}, ZOrder = zOerders.back,})
  local group2GrayWidth = calcWidth(315) or 315
  local groupWhiteHeight = props["Port Information"].Value=="Basic+PoE" and 380 or props["Port Information"].Value=="Basic+PoE+Packets" and 645 or 310 -- 625
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.White, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {group2GrayWidth, groupWhiteHeight}, ZOrder = zOerders.back,})

  local perPage = 16
  local cellW   = 100

  for idx = startIf, endIf do
    local col = idx - startIf
    local x   = col * cellW
    -- Enable
    layout[string.format("PortLabel %d", idx)] = { PrettyName = string.format("%s~Port~Port %d", PageName, idx), Style = "TextBox", Position = { x + 110, 95 }, Color = Colors.White0, Size = labels.size2, StrokeWidth = 0, Margin = 2, FontSize = 12, HTextAlign  = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
    layout[string.format("Enable/Disable Port %d", idx)] = { PrettyName = string.format("%s~Enable~Enable %d", PageName, idx), Style = "Button", ButtonStyle  = "Toggle", Position = { x + 140, 115 }, Size = btns.size2, Cornaradius = 3, StrokeWidth = 1, Color = {16,16,255}, UnlinkOffColor = true, OffColor = {124,124,124}, ZOrder = zOerders.ctrl,}
    layout[string.format("Interface %d", idx)] = { PrettyName = string.format("%s~Interface~Interface %d", PageName, idx), Style = "TextBox", Position = { x + 110, 135 }, Color = Colors.White0, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
    layout[string.format("Comment %d", idx)] = { PrettyName = string.format("%s~Comment~Comment %d", PageName, idx), Style = "TextBox", Position = { x + 110, 155 }, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", ZOrder = zOerders.ctrl,}
    layout[string.format("Running %d", idx)] = { PrettyName = string.format("%s~Running~Running %d", PageName, idx), Style = "LED", Position = { x + 150, 175 }, Size = leds.size, Margin = 2, Color = Colors.Blue, ZOrder = zOerders.ctrl,}
    layout[string.format("LinkSpeed %d", idx)] = { PrettyName = string.format("%s~LinkSpeed~LinkSpeed %d", PageName, idx), Style = "TextBox", Position = { x + 110, 195 }, Color = Colors.White0, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
    -- PoE Enable
    layout[string.format("Enable/Disable PoE %d", idx)] = { PrettyName = string.format("%s~PoE Enable~PoE Enable %d", PageName, idx), Style = "Button", ButtonStyle  = "Toggle", Position = { x + 140, 235 }, Size = btns.size2, Cornaradius = 3, StrokeWidth = 1, Color = {0,255,0}, UnlinkOffColor = true, OffColor = {124,124,124}, ZOrder = zOerders.ctrl,}
    layout[string.format("PoeMode %d", idx)] = { PrettyName = string.format("%s~PoE Mode~PoE Mode %d", PageName, idx), Style = "TextBox", Position = { x + 110, 255 }, Color = Colors.LightYellow, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
    layout[string.format("PoeStatus %d", idx)] = { PrettyName = string.format("%s~PoE State~PoE State %d", PageName, idx), Style = "LED", Position = { x + 150, 275 }, Size = leds.size, Margin = 2, Color = Colors.OnlineGreen, ZOrder = zOerders.ctrl,}

    if props["Port Information"].Value == "Basic+PoE" or props["Port Information"].Value == "Basic+PoE+Packets" then
      layout[string.format("PoeOutStatus %d", idx)] = { PrettyName = string.format("%s~PoE Out Status~PoE Out Status %d", PageName, idx), Style = "TextBox", Position = { x + 110, 295 }, Color = Colors.LightYellow, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("PoeOutPower %d", idx)] = { PrettyName = string.format("%s~PoE Out Power~PoE Out Power %d", PageName, idx), Style = "TextBox", Position = { x + 110, 315 }, Color = Colors.LightYellow, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("PoeOutVoltage %d", idx)] = { PrettyName = string.format("%s~PoE Out Voltage~PoE Out Voltage %d", PageName, idx), Style = "TextBox", Position = { x + 110, 335 }, Color = Colors.LightYellow, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("PoeOutCurrent %d", idx)] = { PrettyName = string.format("%s~PoE Out Current Ampere~PoE Out Current Ampere %d", PageName, idx), Style = "TextBox", Position = { x + 110, 355 }, Color = Colors.LightYellow, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
    end
    if props["Port Information"].Value == "Basic+PoE+Packets" then
      layout[string.format("ReceivedByte %d", idx)] = { PrettyName = string.format("%s~Received~Received Byte %d", PageName, idx), Style = "TextBox", Position = { x + 110, 395 }, Color = Colors.Orange, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("ReceivedUnicast %d", idx)] = { PrettyName = string.format("%s~Received~Received Unicast %d", PageName, idx), Style = "TextBox", Position = { x + 110, 415 }, Color = Colors.Orange, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("ReceivedMulticast %d", idx)] = { PrettyName = string.format("%s~Received~Received Multicast %d", PageName, idx), Style = "TextBox", Position = { x + 110, 435 }, Color = Colors.Orange, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("ReceivedBroadcast %d", idx)] = { PrettyName = string.format("%s~Received~Received Broadcast %d", PageName, idx), Style = "TextBox", Position = { x + 110, 455 }, Color = Colors.Orange, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("ReceivedError %d", idx)] = { PrettyName = string.format("%s~Received~Received Error %d", PageName, idx), Style = "TextBox", Position = { x + 110, 475 }, Color = Colors.Orange, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}

      layout[string.format("TransmittedByte %d", idx)] = { PrettyName = string.format("%s~Transmitted~Transmitted Byte %d", PageName, idx), Style = "TextBox", Position = { x + 110, 515 }, Color = Colors.LightBlue, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("TransmittedUnicast %d", idx)] = { PrettyName = string.format("%s~Transmitted~Transmitted Unicast %d", PageName, idx), Style = "TextBox", Position = { x + 110, 535 }, Color = Colors.LightBlue, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("TransmittedMulticast %d", idx)] = { PrettyName = string.format("%s~Transmitted~Transmitted Multicast %d", PageName, idx), Style = "TextBox", Position = { x + 110, 555 }, Color = Colors.LightBlue, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("TransmittedBroadcast %d", idx)] = { PrettyName = string.format("%s~Transmitted~Transmitted Broadcast %d", PageName, idx), Style = "TextBox", Position = { x + 110, 575 }, Color = Colors.LightBlue, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
      layout[string.format("TransmittedDropped %d", idx)] = { PrettyName = string.format("%s~Transmitted~Transmitted Dropped %d", PageName, idx), Style = "TextBox", Position = { x + 110, 595 }, Color = Colors.LightBlue, Size = labels.size2, Margin = 2, FontSize = 12, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}

      layout[string.format("DeviceMAC %d", idx)] = { PrettyName = string.format("%s~Device's MAC~Device's MAC Address %d", PageName, idx), Style = "TextBox", Position = { x + 110, 620 }, Color = Colors.LightGray, Size = labels.size2, Margin = 2, FontSize = 11, HTextAlign = "Center", IsReadOnly = true, ZOrder = zOerders.ctrl,}
    end
  end

elseif pageIndex == eventPg then
  -- Event Log
  table.insert(graphics,{Type = "Svg", Image = made_logo, Position = {103, 12}, Size = {294,38}, ZOrder = zOerders.front, })

  table.insert(graphics,{Type = "Text", Text = "Event Log", Position = {5,67}, Color = Colors.Black, Size = {200,22}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Left", ZOrder = zOerders.labels})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {500,62}, ZOrder = zOerders.back,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {4,90}, Size = {492,566}, ZOrder = zOerders.back,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.White, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {500,683}, ZOrder = zOerders.back,})

  layout["LogMsg"] = {PrettyName = "Event Log~Log Message", Style = "ListBox", Position = {10,115}, Size = {480,513}, FontSize = 9, StrokeWidth = 1, HTextAlign = "Left", VTextAlign = "Top", ZOrder = zOerders.ctrl }

  layout["GetLog"] = {PrettyName = "Event Log~Get Log", Style = "Button", ButtonStyle = "Trigger", Position = {220,93}, Size = btns.size, CornerRadius = 2, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, Legend = "Get", ZOrder = zOerders.ctrl }
  layout["LogClear"] = {PrettyName = "Event Log~Clear", Style = "Button", ButtonStyle = "Trigger", Position = {440,93}, Size = btns.size, CornerRadius = 2, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, Legend = "Clear", ZOrder = zOerders.ctrl }

elseif props["Enable SSH Terminal"].Value and pageIndex == sshPg then
  -- SSH Terminal
  table.insert(graphics,{Type = "Svg", Image = made_logo, Position = {103, 12}, Size = {294,38}, ZOrder = zOerders.front, })
  local sLabels = {
    text = {"SSH Username","SSH Password","Discconnet Time","(seconds)",},
    pos = {{139,67},{140,85},{140,103},{350,103},},
    size = {labels.size,labels.size,labels.size,{50,18}}
  }
  for i=1, #sLabels.text do
    table.insert(graphics,{Type = "Text",Text = sLabels.text[i],Position = sLabels.pos[i],Color = Colors.Black, Size = sLabels.size[i], FontSize = sLabels.text[i]=="(seconds)" and 10 or 12, Font ="Roboto", HTextAlign = sLabels.text[i]=="(seconds)" and "Left" or "Right", ZOrder = zOerders.labels})
  end
  table.insert(graphics,{Type = "Text", Text = utf8.char(0x3E), Position = {10,649}, StrokeWidth = 0, Size = {18,18}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Left", ZOrder = zOerders.labels})

  table.insert(graphics,{Type = "Text", Text = "SSH Terminal", Position = {5,67}, Color = Colors.Black, Size = {200,22}, FontSize = 18, Font ="Roboto", FontStyle = "Bold", HTextAlign = "Left", ZOrder = zOerders.labels})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {500,62}, ZOrder = zOerders.back,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.Background, CornerRadius = 0, StrokeWidth = 0, Position = {4,124}, Size = {492,553}, ZOrder = zOerders.back,})
  table.insert(graphics,{Type = "GroupBox", Fill = Colors.White, CornerRadius = 0, StrokeWidth = 0, Position = {0,0}, Size = {500,683}, ZOrder = zOerders.back,})

  layout["SSHUsername"] = {PrettyName = "SSH Terminal~SSH User Name", Style = "TextBox", Position = {275,67}, Size = clabels.size, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["SSHPassword"] = {PrettyName = "SSH Terminal~SSH Password", Style = "TextBox", Position = {275,85}, Size = clabels.size, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["SSHTimeOut"] = {PrettyName = "SSH Terminal~TimeOut Time", Style = "TextBox", Position = {275,103}, Color = {110,198,241}, Size = {75,18}, FontSize = 12, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["SSHTimeOutDisplay"] = {PrettyName = "SSH Terminal~TimeOut Remain Display", Style = "TextBox", Position = {424,103}, Color = Colors.LightGray, Size = {36,16}, FontSize = 9, StrokeWidth = 1, HTextAlign = "Center", ZOrder = zOerders.ctrl }
  layout["SSHConnected"] = { PrettyName = "SSH Terminal~Connected", Style = "LED", Position = {10,131}, Size = {12,12}, Color = Colors.Blue, Margin = 0, Padding = 0, StrokeWidth = 0, ZOrder = zOerders.ctrl}
  layout["SSHOutput"] = {PrettyName = "SSH Terminal~Debug Message", Style = "TextBox", Position = {10,149}, Size = {480,500}, FontSize = 12, Padding = 5, StrokeWidth = 1, HTextAlign = "Left", VTextAlign = "Top", ZOrder = zOerders.ctrl }
  layout["SSHInput"] = {PrettyName = "SSH Terminal~Command Input", Style = "TextBox", Position = {25,649}, Size = {425,18}, FontSize = 12, Padding = 0, StrokeWidth = 1, HTextAlign = "Left", VTextAlign = "Center", ZOrder = zOerders.ctrl }

  layout["SSHConnect"] = {PrettyName = "SSH Terminal~Connect", Style = "Button", ButtonStyle = "Trigger", Position = {26,127}, Size = btns.size, CornerRadius = 2, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, Legend = "Connect", ZOrder = zOerders.ctrl }
  layout["SSHDisconnect"] = {PrettyName = "SSH Terminal~Disconnect", Style = "Button", ButtonStyle = "Trigger", Position = {220,127}, Size = btns.size, CornerRadius = 2, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, Legend = "Disconnect", ZOrder = zOerders.ctrl }
  layout["SSHClear"] = {PrettyName = "SSH Terminal~Clear", Style = "Button", ButtonStyle = "Trigger", Position = {440,127}, Size = btns.size, CornerRadius = 2, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, Legend = "Clear", ZOrder = zOerders.ctrl }
  layout["SSHSend"] = {PrettyName = "SSH Terminal~Send", Style = "Button", ButtonStyle = "Trigger", Position = {450,649}, Size = {40,18}, CornerRadius = 0, Margin = 0, Padding = 0, StrokeWidth = 1, FontSize = 9, ZOrder = zOerders.ctrl }

end
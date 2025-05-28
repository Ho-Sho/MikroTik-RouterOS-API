local pageNames = {}
-- always show the Setup page
table.insert(pages, { name = "Setup" })
table.insert(pageNames, "Setup")
-- get max interfaces as a number
local maxIf     = tonumber(props["Total Interfaces"].Value) or 0
local perPage   = 16
local totalPages = math.ceil(maxIf / perPage)
-- create one page per 16 interfaces
for i = 1, totalPages do
  local startIf = (i - 1) * perPage + 1
  local endIf   = math.min(i * perPage, maxIf)
  local label   = string.format("Interfaces %d-%d", startIf, endIf)
  table.insert(pages, { name = label })
  table.insert(pageNames,  label)
end
-- always show Event Log
table.insert(pages, { name = "Event Log" })
table.insert(pageNames, "Event Log")
-- optionally show SSH Terminal if enabled
if props["Enable SSH Terminal"].Value then
  table.insert(pages, { name = "SSH Terminal" })
  table.insert(pageNames, "SSH Terminal")
end

PageNames = pageNames
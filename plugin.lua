-- MikroTik RouterOS API Plugin
-- by Hori Shogo, with contributions from John Ellis
-- May 2025

-- Information block for the plugin
--[[ #include "info.lua" ]]

function GetColor(props) return { 0, 0, 0 } end

function GetPrettyName(props)
  return "MikroTik RouterOS API \nv" .. PluginInfo.Version .. ",\nTotal " .. tostring(props["Total Interfaces"].Value) .. " Port"
end

local PageNames = {}
function GetPages(props)
  local pages = {}
  --[[ #include "pages.lua" ]]
  return pages
end

-- Define User configurable Properties of the plugin
function GetProperties()
  local props = {}
  --[[ #include "properties.lua" ]]
  return props
end

function RectifyProperties(props)
  --[[ #include "rectify_properties.lua" ]]
  return props
end

-- Defines the Controls used within the plugin
function GetControls(props)
  local ctrls = {}
  --[[ #include "controls.lua" ]]
  return ctrls
end

--Layout of controls and graphics for the plugin UI to display
function GetControlLayout(props)
  local layout = {}
  local graphics = {}
  --[[ #include "layout.lua" ]]
  return layout, graphics
end

--Start event based logic
if Controls then
  --[[ #include "runtime.lua" ]]
end
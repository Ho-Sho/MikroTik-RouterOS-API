local TextControls = {
  Name = {"IPAddress","APIUsername","APIPassword","InterfaceToCore","SystemName","SoftwareID","nLevel","FactoryFirmwareVersion","FirmwareVersion","Uptime","BoardName","Model","SerialNumber","FirmewareType",
"SSHUsername","SSHPassword","RealSSHPass","SSHTimeOutDisplay","SSHInput","SSHOutput","LogMsg"},
  PinStyle = {"Both","Both","Both","Both","Output","Output","Output","Output","Output","Output","Output","Output","Output","Output","Output",
"Both","Both","None","Both","Output","Both","Output","Output"}
}
local ButtonControls = {
  Name = {"Enable/Disable Port","Enable/Disable PoE"},
}
local TriButtonControls = {
  Name = {"SSHConnect","SSHClear","SSHDisconnect","SSHSend","GetLog","LogClear","Reboot"},
}
local IndicatorControls = {
  Name = {"Running","PoeStatus","SSHConnected"},
  Count = {props["Total Interfaces"].Value,props["Total Interfaces"].Value,1},
}
local ReadControls = {
  Name = {"Interface","Comment","PortLabel","PoeMode","LinkSpeed","ReceivedByte","ReceivedUnicast","ReceivedMulticast","ReceivedBroadcast","ReceivedError",
  "TransmittedByte","TransmittedUnicast","TransmittedMulticast","TransmittedBroadcast","TransmittedDropped",
  "DeviceMAC","PoeVoltage","PoeOutStatus","PoeOutVoltage","PoeOutCurrent","PoeOutPower"}
}

--Arrays of Controls
for i=1,#TextControls.Name do
  table.insert(ctrls, {
    Name = TextControls.Name[i],
    ControlType = "Text",
    Count = 1,
    UserPin = true,
    PinStyle = TextControls.PinStyle[i],
  })
end
for i=1,#ButtonControls.Name do
  table.insert(ctrls, {
    Name = ButtonControls.Name[i],
    ControlType = "Button",
    ButtonType = "Toggle",
    Count = props["Total Interfaces"].Value,
    UserPin = true,
    PinStyle = "Both",
  })
end
for i=1,#TriButtonControls.Name do
  table.insert(ctrls, {
    Name = TriButtonControls.Name[i],
    ControlType = "Button",
    ButtonType = "Trigger",
    Count = 1,
    IconType = TriButtonControls.Name[i]=="SSHSend" and "Icon" or nil,
    Icon = TriButtonControls.Name[i]=="SSHSend" and "Arrow Right" or nil,
    UserPin = true,
    PinStyle = "Both",
  })
end
for i=1,#IndicatorControls.Name do
  table.insert(ctrls, {
    Name = IndicatorControls.Name[i],
    ControlType = "Indicator",
    IndicatorType = "Led",
    Count = IndicatorControls.Count[i],
    UserPin = true,
    PinStyle = "Output",
  })
end
for i=1,#ReadControls.Name do
  table.insert(ctrls, {
    Name = ReadControls.Name[i],
    ControlType = "Text",
    Count = props["Total Interfaces"].Value,
    UserPin = true,
    PinStyle = i==2 and "Both" or "Output",
  })
end

----------------------------------------------------------------
table.insert(ctrls, { Name = "SSHTimeOut", ControlType = "Knob", ControlUnit = "Integer", Count = 1, DefaultValue = 30, Max = 120, Min = 0, UserPin = true, PinStyle = "Output",})
table.insert(ctrls, { Name = "Status", ControlType = "Indicator", IndicatorType = "Status", Count = 1, UserPin = true, PinStyle = "Output",})
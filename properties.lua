table.insert(props, {
  Name = "Total Interfaces",
  Type = "integer",
  Min = 5,
  Max = 1023,
  Value = 18,
  Header = "Value must be number between 5 and 1023",
  --Comment = "Value must be number between 5 and 1023"
})
table.insert(props, {
  Name = "Connection Type",
  Type = "enum",
  Choices = {"TCP", "TLS"},
  Value = "TCP",
  Header  = "Choose TCP or TLS for the API connection",
})
table.insert(props, {
  Name = "Enable SSH Terminal",
  Type = "boolean",
  Value = false
})
table.insert(props, {
  Name = "Port Information",
  Type = "enum",
  Choices = {"Basic", "Basic+PoE", "Basic+PoE+Packets"},
  Value = "Basic"
})
table.insert(props, {
  Name = "Poll Rate(sec)",
  Type = "integer",
  Min = 1,
  Max = 600,
  Value = 3,
  Header = "Value must be number between 1 and 600",
  --Comment = "Value must be number between 1 and 600"
})
table.insert(props, {
  Name = "Debug Print",
  Type = "enum",
  Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function", "All"},
  Value = "All"
})
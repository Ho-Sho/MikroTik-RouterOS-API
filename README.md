# MikroTik RouterOS API Plugin Readme

## Overview

The MikroTik RouterOS API Plugin is a powerful tool designed to interact with MikroTik RouterOS devices through their API. Developed by Hori Shogo with contributions from John Ellis, version 1.0.0 allows users to monitor and manage MikroTik devices using a user-friendly interface. The plugin supports both TCP and TLS connections for secure communication with devices.

## Features

- **Device Connection**: Establish connections to MikroTik devices using either TCP (port 8728) or TLS (port 8729).
- **Interface Management**: View and manage interface details, including enabling/disabling ports and Power over Ethernet (PoE).
- **SSH Terminal**: Optionally enable an SSH terminal for direct command execution on the device.
- **Event Logging**: Retrieve and display event logs from the MikroTik device.
- **Device Information**: Access system details such as system name, model, serial number, firmware version, and uptime.
- **Reboot Functionality**: Remotely reboot the device as needed.

## Installation

1. **Download the Plugin**: Obtain the plugin file `MikroTik-Plugin-v1.0.0.qplug` from the repository.
2. **Load the Plugin**: Install the Plugin
   - Double-click the plugin file. This action will automatically install the plugin into the appropriate directory within the QSC Designer folder.
   - Verify the Plugin in QSC Designer.
   - Launch QSC Designer.
   - Navigate to the "Plugins" menu.
   - Under the "User" section, you should see a folder named "MikroTik". The installed plugin will be located within this folder.

## Configuration

To configure the plugin, follow these steps:

1. **Connection Setup**:
   - **IP Address**: Enter the IP address of the MikroTik device.
   - **API Username**: Provide the API username for authentication.
   - **API Password**: Input the corresponding API password.
   - **Connection Type**: Select either `TCP` or `TLS` based on your security requirements.

2. **Interface to Core**:
   - Choose the interface that connects to the core network from the available options.

3. **Enable SSH Terminal**:
   - Optionally enable the SSH terminal by setting `Enable SSH Terminal` to `true` for direct command execution.

4. **Port Information**:
   - Select the level of detail for port information: `Basic`, `Basic+PoE`, or `Basic+PoE+Packets`.

5. **Poll Rate**:
   - Set the polling interval (in seconds, between 1 and 600) for updating device information.

6. **Debug Print**:
   - Choose the debug level: `None`, `Tx/Rx`, `Tx`, `Rx`, `Function`, or `All` to control the verbosity of debug output.

## Usage

The plugin interface is divided into several pages, each serving a specific purpose:

1. **Setup Page**:
   - Configure connection settings and view device information.
   - Monitor connection status and reboot the device if necessary.

2. **Interfaces Page**:
   - View and manage individual interfaces (up to 16 per page).
   - Enable/disable ports and PoE, edit interface comments, and view detailed port statistics based on the `Port Information` setting.

3. **Event Log Page**:
   - Retrieve and display event logs from the device.
   - Clear the log display as needed.

4. **SSH Terminal Page** (if enabled):
   - Connect to the device via SSH using the configured username and password.
   - Execute commands directly and view the output.
   - Manage connection timeout settings (0 to 120 seconds).

## Notes

- **Compatibility**: The plugin operates only with MikroTik RouterOS devices that support API access.
- **TLS Requirements**: For TLS connections, ensure the device supports TLS and is properly configured.
- **Network Access**: The device must be accessible over the network from the host running the plugin.
- **SSH Security**: SSH credentials are required for each connection if the terminal is enabled.
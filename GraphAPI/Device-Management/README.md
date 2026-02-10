# Device Management Scripts

This folder contains Graph API scripts for device operations.

## Purpose

Scripts in this folder use Microsoft Graph API to:
- Query device information
- Perform remote actions
- Manage device compliance
- Bulk device operations
- Device lifecycle management

## Example Scripts

Place scripts here such as:
- `Get-AllDevices.ps1` - Retrieve all managed devices
- `Get-DeviceCompliance.ps1` - Query device compliance status
- `Invoke-DeviceSync.ps1` - Trigger device sync remotely
- `Remove-StaleDevices.ps1` - Clean up inactive devices
- `Retire-Devices.ps1` - Bulk retire devices
- `Wipe-Devices.ps1` - Remote wipe devices
- `Get-DeviceConfiguration.ps1` - Get applied configurations

## Graph API Endpoints Used

- `/deviceManagement/managedDevices`
- `/deviceManagement/managedDevices/{id}/syncDevice`
- `/deviceManagement/managedDevices/{id}/retire`
- `/deviceManagement/managedDevices/{id}/wipe`

## Required Permissions

- DeviceManagementManagedDevices.Read.All
- DeviceManagementManagedDevices.ReadWrite.All (for write operations)

## Authentication

Refer to the parent GraphAPI folder README for authentication setup.

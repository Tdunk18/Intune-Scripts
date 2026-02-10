# Active Directory Scripts

This folder contains scripts for managing Active Directory Domain Services during and after migration to Intune.

## Purpose

Scripts in this folder help with:
- User and computer object management
- Group management for cloud sync
- OU structure organization
- Attribute updates for Azure AD Connect
- Cleanup of legacy objects

## Example Scripts

Place scripts here such as:
- `Sync-ADAttributes.ps1` - Update AD attributes for cloud sync
- `Get-ADComputerInventory.ps1` - Inventory AD computer objects
- `Set-CloudSyncAttributes.ps1` - Prepare objects for Azure AD sync
- `Cleanup-StaleComputers.ps1` - Remove inactive computer objects
- `Export-ADGroups.ps1` - Export groups for cloud migration
- `Update-ADUserAttributes.ps1` - Set user attributes for hybrid scenarios

## Hybrid Scenarios

These scripts are particularly useful for:
- **Hybrid Azure AD Join**: Preparing computer objects
- **Azure AD Connect**: Setting required attributes
- **Device Writeback**: Managing device objects in AD
- **Group Policy Transition**: Organizing OUs for co-management

## Prerequisites

- Active Directory PowerShell module
- Appropriate AD administrative permissions
- Azure AD Connect configured (for hybrid scenarios)

## Common Attributes for Cloud Sync

- `userPrincipalName`
- `mail`
- `proxyAddresses`
- `extensionAttribute1-15` (for custom sync rules)

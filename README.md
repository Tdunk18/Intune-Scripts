# Intune-Scripts

A comprehensive PowerShell module for managing Microsoft Intune device migrations, policy assignments, and Graph API integration. This module provides enterprise-grade tools for Hybrid and Entra Join migrations with built-in validation, reporting, and rollback capabilities.

## Features

### 1. Device and Policy Management
- **Device Scope Selection**: Filter and manage devices by type (iOS, Android, macOS, Windows)
- **Policy Assignment**: Comprehensive policy assignment management for compliance, configuration, and app protection policies
- **Pilot-Friendly Implementation**: Test policies on pilot groups before production rollout
- **Rollback Plans**: Automated backup and rollback procedures with documented recovery steps

### 2. Validation and Reporting
- **Pre-Migration Checks**: 
  - Validate device readiness (co-management, hybrid AD-join status)
  - Check user licensing (Intune license verification)
  - Dependency validation for apps and policies
- **Migration Reporting**:
  - Pre- and post-migration comparison reports
  - Device compliance analytics
  - Error tracking and issue identification
  - Export to JSON, CSV, and HTML formats

### 3. Graph API Integration
- **Microsoft Graph Support**: Full integration with Microsoft Graph API using the Microsoft.Graph PowerShell module
- **OData Querying**: Efficient data filtering with `$filter`, `$expand`, and `$select` support
- **Rate Limiting and Retries**: Built-in exponential backoff and retry logic for API throttling

## Installation

### Prerequisites
- PowerShell 5.1 or higher
- Microsoft.Graph.Authentication module (v2.0.0 or higher)
- Microsoft.Graph.DeviceManagement module (v2.0.0 or higher)

### Install from Repository

1. Clone this repository:
```powershell
git clone https://github.com/Tdunk18/Intune-Scripts.git
cd Intune-Scripts
```

2. Import the module:
```powershell
Import-Module .\IntuneScripts.psd1
```

### Install Required Dependencies

```powershell
Install-Module -Name Microsoft.Graph.Authentication -MinimumVersion 2.0.0
Install-Module -Name Microsoft.Graph.DeviceManagement -MinimumVersion 2.0.0
```

## Quick Start

### 1. Connect to Microsoft Graph

```powershell
Connect-IntuneGraph
```

### 2. Get Devices by Scope

```powershell
# Get all Windows devices
$windowsDevices = Get-IntuneDevicesByScope -DeviceType Windows

# Get iOS and Android devices with compliance info
$mobileDevices = Get-IntuneDevicesByScope -DeviceType iOS,Android -IncludeCompliance
```

### 3. Create a Pilot Group and Test Policy

```powershell
# Create a pilot group
$pilotGroup = New-PilotGroup -GroupName "Intune-Pilot-Windows" -Description "Windows pilot group"

# Assign policy to pilot group
Test-PilotDeployment -PolicyId "policy123" -PolicyType Compliance -PilotGroupId $pilotGroup.id

# After successful testing, expand to production
Expand-PilotToProduction -PolicyId "policy123" -PolicyType Compliance -ProductionGroupIds @("prod-group-1", "prod-group-2")
```

### 4. Run Pre-Migration Validation

```powershell
# Check device readiness
$readiness = Test-DeviceReadiness -DeviceType Windows

# Validate user licensing
$licensing = Test-UserLicensing -GroupId "target-group-id"

# Check policy dependencies
$dependencies = Test-Dependencies -PolicyId "policy123" -PolicyType Configuration
```

### 5. Create Rollback Plan

```powershell
# Backup policies and create rollback documentation
$rollbackPlan = New-RollbackPlan -PolicyIds @("policy1", "policy2") -PolicyType Compliance -Description "Q1 2026 compliance update"

# If needed, restore from backup
Restore-PolicyConfiguration -BackupFile "PolicyBackup_Compliance_policy123_20260210-120000.json"
```

### 6. Generate Reports

```powershell
# Pre-migration baseline
$preReport = Export-PreMigrationReport -DeviceType Windows -OutputPath "C:\Reports"

# Migration report
$migrationReport = Get-MigrationReport -DeviceType Windows -Format HTML -OutputPath "C:\Reports"

# Compliance report
$complianceReport = Get-ComplianceReport -DeviceType All -OutputPath "C:\Reports"

# Post-migration comparison
$postReport = Export-PostMigrationReport -PreMigrationReportPath $preReport -DeviceType Windows
```

## Module Functions

### Device Management
| Function | Description |
|----------|-------------|
| `Get-IntuneDevicesByScope` | Retrieve devices filtered by type |
| `Set-DeviceScope` | Configure device scope for operations |

### Policy Management
| Function | Description |
|----------|-------------|
| `New-PolicyAssignment` | Create new policy assignment |
| `Get-PolicyAssignments` | Retrieve policy assignments |
| `Set-PolicyAssignment` | Update policy assignment |
| `Remove-PolicyAssignment` | Delete policy assignment |

### Pilot Testing
| Function | Description |
|----------|-------------|
| `New-PilotGroup` | Create pilot testing group |
| `Test-PilotDeployment` | Deploy and monitor pilot |
| `Expand-PilotToProduction` | Expand successful pilot to production |

### Rollback
| Function | Description |
|----------|-------------|
| `Backup-PolicyConfiguration` | Backup policy settings |
| `Restore-PolicyConfiguration` | Restore from backup |
| `New-RollbackPlan` | Generate rollback documentation |

### Validation
| Function | Description |
|----------|-------------|
| `Test-DeviceReadiness` | Validate device migration readiness |
| `Test-UserLicensing` | Check user license compliance |
| `Test-Dependencies` | Verify policy dependencies |

### Reporting
| Function | Description |
|----------|-------------|
| `Get-MigrationReport` | Comprehensive migration report |
| `Get-ComplianceReport` | Compliance status report |
| `Export-PreMigrationReport` | Pre-migration baseline |
| `Export-PostMigrationReport` | Post-migration comparison |

### Graph API
| Function | Description |
|----------|-------------|
| `Connect-IntuneGraph` | Connect to Microsoft Graph |
| `Invoke-IntuneGraphRequest` | Execute Graph API request with retry |
| `Get-IntuneGraphData` | Retrieve data with OData support |

## Advanced Usage Examples

### Example 1: Complete Migration Workflow

```powershell
# 1. Connect to Graph
Connect-IntuneGraph

# 2. Run pre-migration validation
$preReport = Export-PreMigrationReport -DeviceType Windows
$readiness = Test-DeviceReadiness -DeviceType Windows
$licensing = Test-UserLicensing -GroupId "migration-target-group"

# 3. Create rollback plan
$rollbackPlan = New-RollbackPlan -PolicyIds @("policy1", "policy2") -PolicyType Compliance

# 4. Test on pilot group
$pilotGroup = New-PilotGroup -GroupName "Migration-Pilot"
Test-PilotDeployment -PolicyId "policy1" -PolicyType Compliance -PilotGroupId $pilotGroup.id

# 5. Monitor and expand to production
Expand-PilotToProduction -PolicyId "policy1" -PolicyType Compliance -ProductionGroupIds @("prod-group")

# 6. Generate post-migration report
$postReport = Export-PostMigrationReport -PreMigrationReportPath $preReport
```

### Example 2: Using OData Queries

```powershell
# Get Windows devices that haven't synced in 7 days
$staleDevices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows' and lastSyncDateTime lt $((Get-Date).AddDays(-7).ToString('yyyy-MM-dd'))" `
    -Select "id,deviceName,lastSyncDateTime"

# Get non-compliant iOS devices
$nonCompliantIOS = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'iOS' and complianceState eq 'noncompliant'" `
    -Expand "deviceCompliancePolicyStates"
```

### Example 3: Bulk Policy Assignment

```powershell
$policies = @("policy1", "policy2", "policy3")
$targetGroups = @("group1", "group2")

foreach ($policy in $policies) {
    # Create rollback backup
    Backup-PolicyConfiguration -PolicyId $policy -PolicyType Configuration
    
    # Assign to groups
    foreach ($group in $targetGroups) {
        New-PolicyAssignment -PolicyId $policy -PolicyType Configuration -GroupId $group
    }
}
```

## Error Handling and Retry Logic

The module includes built-in error handling for common scenarios:

- **Graph API Throttling (429)**: Automatic retry with exponential backoff
- **Service Unavailable (503)**: Retry with progressive delays
- **Retry-After Header**: Respects server-specified retry delays
- **Maximum Retries**: Configurable retry limits (default: 5)

## Best Practices

1. **Always run pre-migration validation** before making changes
2. **Create rollback plans** for all production changes
3. **Test on pilot groups** before production deployment
4. **Monitor compliance** after policy changes
5. **Generate reports** for documentation and auditing
6. **Use device scopes** to target specific device types
7. **Validate dependencies** before policy deployment

## Troubleshooting

### Connection Issues
```powershell
# Reconnect with specific scopes
Connect-IntuneGraph -Scopes @('DeviceManagementConfiguration.ReadWrite.All')

# Use device code flow for non-interactive scenarios
Connect-IntuneGraph -UseDeviceCode
```

### API Throttling
The module automatically handles throttling, but you can monitor retry attempts:
```powershell
$VerbosePreference = 'Continue'
Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
```

### Missing Permissions
Ensure you have the required Graph API permissions:
- `DeviceManagementConfiguration.ReadWrite.All`
- `DeviceManagementManagedDevices.ReadWrite.All`
- `DeviceManagementApps.ReadWrite.All`
- `Group.ReadWrite.All`
- `Directory.Read.All`

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the terms of the LICENSE file included in this repository.

## Support

For issues, questions, or contributions, please visit:
https://github.com/Tdunk18/Intune-Scripts/issues 

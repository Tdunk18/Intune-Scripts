# Getting Started with IntuneScripts

## Quick Start Guide

This guide will help you get started with the IntuneScripts PowerShell module for managing Intune device migrations and policy assignments.

## Prerequisites

Before you begin, ensure you have:

1. **PowerShell 5.1 or later**
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **Microsoft Graph PowerShell modules**
   ```powershell
   Install-Module -Name Microsoft.Graph.Authentication -MinimumVersion 2.0.0
   Install-Module -Name Microsoft.Graph.DeviceManagement -MinimumVersion 2.0.0
   ```

3. **Appropriate Azure AD permissions**
   - Global Administrator, Intune Administrator, or custom role with:
     - DeviceManagementConfiguration.ReadWrite.All
     - DeviceManagementManagedDevices.ReadWrite.All
     - Group.ReadWrite.All

## Installation

### Step 1: Clone or Download the Repository

```powershell
# Clone the repository
git clone https://github.com/Tdunk18/Intune-Scripts.git
cd Intune-Scripts
```

### Step 2: Import the Module

```powershell
# Import the module
Import-Module .\IntuneScripts.psd1

# Verify module loaded
Get-Module IntuneScripts
```

### Step 3: Connect to Microsoft Graph

```powershell
# Connect with default scopes
Connect-IntuneGraph

# Or connect with device code (for non-interactive)
Connect-IntuneGraph -UseDeviceCode

# Or specify custom scopes
Connect-IntuneGraph -Scopes @(
    'DeviceManagementConfiguration.ReadWrite.All',
    'Group.ReadWrite.All'
)
```

## Your First Migration

Let's walk through a simple migration scenario.

### Scenario: Migrate Windows Devices with Compliance Policy

#### Step 1: Get Device Inventory

```powershell
# Get all Windows devices
$windowsDevices = Get-IntuneDevicesByScope -DeviceType Windows

# Display summary
Write-Host "Total Windows Devices: $($windowsDevices.Count)"
$windowsDevices | Group-Object complianceState | Select-Object Name, Count
```

#### Step 2: Validate Readiness

```powershell
# Check if devices are ready for migration
$readiness = Test-DeviceReadiness -DeviceType Windows

# Display results
$readyCount = ($readiness | Where-Object { $_.IsReady }).Count
Write-Host "$readyCount out of $($readiness.Count) devices are ready"

# See which devices are not ready
$notReady = $readiness | Where-Object { -not $_.IsReady }
$notReady | Select-Object DeviceName, Issues
```

#### Step 3: Check User Licensing

```powershell
# Check a target group's licensing
$licensing = Test-UserLicensing -GroupId "your-target-group-id"

# Display summary
$licensedCount = ($licensing | Where-Object { $_.HasIntuneLicense }).Count
Write-Host "$licensedCount out of $($licensing.Count) users are licensed"
```

#### Step 4: Generate Pre-Migration Report

```powershell
# Create baseline report
$preReport = Export-PreMigrationReport -DeviceType Windows -OutputPath ".\Reports"

Write-Host "Pre-migration report saved to: $preReport"
```

#### Step 5: Create Rollback Plan

```powershell
# Backup your compliance policy
$policyId = "your-compliance-policy-id"

$rollbackPlan = New-RollbackPlan `
    -PolicyIds @($policyId) `
    -PolicyType Compliance `
    -OutputPath ".\Rollback" `
    -Description "Windows compliance migration"

Write-Host "Rollback plan created: $($rollbackPlan.PlanFile)"
```

#### Step 6: Create Pilot Group

```powershell
# Create a pilot group
$pilotGroup = New-PilotGroup `
    -GroupName "Windows-Migration-Pilot" `
    -Description "Pilot group for Windows device migration"

Write-Host "Pilot group created with ID: $($pilotGroup.id)"
```

#### Step 7: Test on Pilot

```powershell
# Deploy policy to pilot group
$pilotTest = Test-PilotDeployment `
    -PolicyId $policyId `
    -PolicyType Compliance `
    -PilotGroupId $pilotGroup.id

Write-Host "Pilot deployment initiated. Monitor for the next 30-60 minutes."
```

#### Step 8: Monitor Pilot

```powershell
# After 30-60 minutes, check compliance
$complianceReport = Get-ComplianceReport `
    -PolicyId $policyId `
    -PolicyType Compliance `
    -DeviceType Windows

# Review the report to ensure pilot is successful
```

#### Step 9: Expand to Production

```powershell
# After successful pilot testing
$productionGroupIds = @("production-group-id-1", "production-group-id-2")

Expand-PilotToProduction `
    -PolicyId $policyId `
    -PolicyType Compliance `
    -ProductionGroupIds $productionGroupIds `
    -RemovePilotAssignment `
    -PilotGroupId $pilotGroup.id

Write-Host "Policy expanded to production!"
```

#### Step 10: Post-Migration Validation

```powershell
# Generate post-migration report
$postReport = Export-PostMigrationReport `
    -PreMigrationReportPath $preReport `
    -DeviceType Windows `
    -OutputPath ".\Reports"

Write-Host "Post-migration report saved to: $postReport"

# Review the success rate and identify any issues
```

## Common Tasks

### List All Available Functions

```powershell
Get-Command -Module IntuneScripts
```

### Get Help for a Function

```powershell
Get-Help Connect-IntuneGraph -Full
Get-Help Test-DeviceReadiness -Examples
```

### Filter Devices with OData

```powershell
# Get non-compliant Windows devices
$nonCompliant = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows' and complianceState eq 'noncompliant'"

# Get devices that haven't synced in 7 days
$staleDate = (Get-Date).AddDays(-7).ToString('yyyy-MM-dd')
$staleDevices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "lastSyncDateTime lt $staleDate"
```

### Create Policy Assignment

```powershell
# Assign a compliance policy to a group
New-PolicyAssignment `
    -PolicyId "policy-id" `
    -PolicyType Compliance `
    -GroupId "group-id" `
    -AssignmentType Include
```

### Backup and Restore Policies

```powershell
# Backup a policy
$backup = Backup-PolicyConfiguration `
    -PolicyId "policy-id" `
    -PolicyType Configuration `
    -BackupPath ".\Backups"

# Restore from backup (if needed)
Restore-PolicyConfiguration -BackupFile $backup
```

## Next Steps

Now that you've completed your first migration, explore more advanced features:

1. **Read the documentation**
   - [GraphAPI-Guide.md](./Docs/GraphAPI-Guide.md) - Learn about Graph API integration
   - [Migration-Best-Practices.md](./Docs/Migration-Best-Practices.md) - Best practices for migrations

2. **Explore examples**
   - [Complete-Migration-Example.ps1](./Examples/Complete-Migration-Example.ps1)
   - [Policy-Assignment-Example.ps1](./Examples/Policy-Assignment-Example.ps1)
   - [Device-Scope-Example.ps1](./Examples/Device-Scope-Example.ps1)
   - [Validation-Reporting-Example.ps1](./Examples/Validation-Reporting-Example.ps1)

3. **Customize for your environment**
   - Modify examples for your specific policies
   - Create custom scripts for repetitive tasks
   - Integrate with your existing automation

## Troubleshooting

### Issue: Module won't import

**Check PowerShell version:**
```powershell
$PSVersionTable.PSVersion
# Should be 5.1 or higher
```

**Import with full path:**
```powershell
Import-Module "C:\full\path\to\IntuneScripts.psd1" -Force
```

### Issue: Can't connect to Graph

**Check module installation:**
```powershell
Get-Module -ListAvailable Microsoft.Graph.Authentication
```

**Reconnect:**
```powershell
Disconnect-MgGraph
Connect-IntuneGraph
```

### Issue: Insufficient permissions

**Check current context:**
```powershell
Get-MgContext | Select-Object Scopes
```

**Reconnect with required scopes:**
```powershell
Disconnect-MgGraph
Connect-IntuneGraph -Scopes @('DeviceManagementConfiguration.ReadWrite.All')
```

## Support

- **Documentation**: Check the [Docs](./Docs) folder
- **Examples**: See the [Examples](./Examples) folder
- **Issues**: Report at https://github.com/Tdunk18/Intune-Scripts/issues

## Tips

1. **Always test on pilot groups first** - Never deploy directly to production
2. **Create rollback plans** - Always have a way to undo changes
3. **Use verbose logging** - Set `$VerbosePreference = 'Continue'` for detailed output
4. **Generate reports** - Document your migrations for compliance and auditing
5. **Monitor compliance** - Check device compliance regularly after changes

## What's Next?

You're now ready to:
- Perform device migrations safely
- Manage policy assignments efficiently
- Validate readiness before changes
- Generate comprehensive reports
- Handle rollbacks when needed

Happy migrating! 🚀

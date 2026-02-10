# Function Reference

Complete reference for all functions in the IntuneScripts PowerShell module.

## Table of Contents

- [Device Management](#device-management)
- [Policy Management](#policy-management)
- [Pilot Testing](#pilot-testing)
- [Rollback and Recovery](#rollback-and-recovery)
- [Validation](#validation)
- [Reporting](#reporting)
- [Graph API](#graph-api)

---

## Device Management

### Get-IntuneDevicesByScope

Retrieves Intune devices filtered by device type scope.

**Parameters:**
- `DeviceType` (Required): iOS, Android, macOS, Windows, or All
- `IncludeCompliance` (Optional): Include compliance status information

**Example:**
```powershell
$windowsDevices = Get-IntuneDevicesByScope -DeviceType Windows -IncludeCompliance
```

**Returns:** Array of managed device objects

---

### Set-DeviceScope

Sets the device scope for subsequent operations.

**Parameters:**
- `DeviceType` (Required): Device types to include in scope
- `GroupName` (Optional): Azure AD group name to scope devices to
- `GroupId` (Optional): Azure AD group ID to scope devices to

**Example:**
```powershell
$scope = Set-DeviceScope -DeviceType Windows,macOS -GroupName "Corporate-Devices"
```

**Returns:** PSCustomObject with scope configuration

---

## Policy Management

### New-PolicyAssignment

Creates a new policy assignment in Intune.

**Parameters:**
- `PolicyId` (Required): The ID of the policy to assign
- `PolicyType` (Required): Compliance, Configuration, AppProtection, or AppConfiguration
- `GroupId` (Required): The Azure AD group ID to assign the policy to
- `AssignmentType` (Optional): Include or Exclude (default: Include)

**Example:**
```powershell
New-PolicyAssignment -PolicyId "abc123" -PolicyType Compliance -GroupId "group123" -AssignmentType Include
```

**Returns:** Assignment object

---

### Get-PolicyAssignments

Retrieves policy assignments from Intune.

**Parameters:**
- `PolicyId` (Required): The ID of the policy
- `PolicyType` (Required): Compliance, Configuration, AppProtection, or AppConfiguration

**Example:**
```powershell
$assignments = Get-PolicyAssignments -PolicyId "abc123" -PolicyType Compliance
```

**Returns:** Array of assignment objects

---

### Set-PolicyAssignment

Updates an existing policy assignment.

**Parameters:**
- `PolicyId` (Required): The ID of the policy
- `PolicyType` (Required): Policy type
- `AssignmentId` (Required): The ID of the assignment to update
- `GroupId` (Required): The new group ID for the assignment

**Example:**
```powershell
Set-PolicyAssignment -PolicyId "abc123" -PolicyType Compliance -AssignmentId "assign123" -GroupId "newgroup123"
```

**Returns:** Updated assignment object

---

### Remove-PolicyAssignment

Removes a policy assignment from Intune.

**Parameters:**
- `PolicyId` (Required): The ID of the policy
- `PolicyType` (Required): Policy type
- `AssignmentId` (Required): The ID of the assignment to remove

**Example:**
```powershell
Remove-PolicyAssignment -PolicyId "abc123" -PolicyType Compliance -AssignmentId "assign123"
```

**Returns:** None

---

## Pilot Testing

### New-PilotGroup

Creates a new Azure AD group for pilot testing.

**Parameters:**
- `GroupName` (Required): The name for the pilot group
- `Description` (Optional): Description for the pilot group
- `MailNickname` (Optional): Mail nickname (defaults to sanitized group name)

**Example:**
```powershell
$pilotGroup = New-PilotGroup -GroupName "Intune-Pilot-iOS" -Description "Pilot group for iOS device testing"
```

**Returns:** Group object

---

### Test-PilotDeployment

Tests a policy deployment on a pilot group.

**Parameters:**
- `PolicyId` (Required): The ID of the policy to deploy
- `PolicyType` (Required): Policy type
- `PilotGroupId` (Required): The ID of the pilot group
- `MonitoringDurationMinutes` (Optional): How long to monitor (default: 30 minutes)

**Example:**
```powershell
Test-PilotDeployment -PolicyId "abc123" -PolicyType Compliance -PilotGroupId "group123"
```

**Returns:** PSCustomObject with deployment information

---

### Expand-PilotToProduction

Expands a pilot deployment to production groups.

**Parameters:**
- `PolicyId` (Required): The ID of the policy to expand
- `PolicyType` (Required): Policy type
- `ProductionGroupIds` (Required): Array of production group IDs
- `RemovePilotAssignment` (Optional): Remove the pilot group assignment
- `PilotGroupId` (Optional): The pilot group ID (required if RemovePilotAssignment is specified)

**Example:**
```powershell
Expand-PilotToProduction -PolicyId "abc123" -PolicyType Compliance -ProductionGroupIds @("prod1", "prod2")
```

**Returns:** Array of assignment objects

---

## Rollback and Recovery

### Backup-PolicyConfiguration

Backs up a policy configuration for rollback purposes.

**Parameters:**
- `PolicyId` (Required): The ID of the policy to backup
- `PolicyType` (Required): Policy type
- `BackupPath` (Optional): Path to save the backup file (default: current directory)

**Example:**
```powershell
$backupPath = Backup-PolicyConfiguration -PolicyId "abc123" -PolicyType Compliance
```

**Returns:** String path to backup file

---

### Restore-PolicyConfiguration

Restores a policy configuration from a backup file.

**Parameters:**
- `BackupFile` (Required): Path to the backup JSON file
- `RestoreAssignmentsOnly` (Optional): Only restore assignments, not policy settings

**Example:**
```powershell
Restore-PolicyConfiguration -BackupFile "PolicyBackup_Compliance_abc123_20260210-120000.json"
```

**Returns:** None

---

### New-RollbackPlan

Creates a rollback plan for policy changes.

**Parameters:**
- `PolicyIds` (Required): Array of policy IDs to include in the rollback plan
- `PolicyType` (Required): Policy type
- `OutputPath` (Optional): Path to save the rollback plan (default: current directory)
- `Description` (Optional): Description of the changes being made

**Example:**
```powershell
$rollbackPlan = New-RollbackPlan -PolicyIds @("abc123", "def456") -PolicyType Compliance -Description "Q1 2026 compliance update"
```

**Returns:** Hashtable with PlanFile and BackupFiles

---

## Validation

### Test-DeviceReadiness

Validates device readiness for migration.

**Parameters:**
- `DeviceIds` (Optional): Array of device IDs to check
- `DeviceType` (Optional): Filter by device type

**Example:**
```powershell
$readiness = Test-DeviceReadiness -DeviceType Windows
```

**Returns:** Array of PSCustomObjects with readiness information

---

### Test-UserLicensing

Validates user licensing for Intune.

**Parameters:**
- `UserIds` (Optional): Array of user IDs to check
- `GroupId` (Optional): Check all users in a specific group
- `RequiredSkuPartNumbers` (Optional): Required SKU part numbers

**Example:**
```powershell
$licensing = Test-UserLicensing -GroupId "group123"
```

**Returns:** Array of PSCustomObjects with licensing information

---

### Test-Dependencies

Validates policy and app dependencies.

**Parameters:**
- `PolicyId` (Required): The policy ID to check dependencies for
- `PolicyType` (Required): Policy type

**Example:**
```powershell
$dependencies = Test-Dependencies -PolicyId "abc123" -PolicyType Configuration
```

**Returns:** PSCustomObject with dependency information

---

## Reporting

### Get-MigrationReport

Generates a comprehensive migration report.

**Parameters:**
- `DeviceType` (Optional): Filter by device type (default: All)
- `GroupId` (Optional): Filter by group
- `OutputPath` (Optional): Path to save the report (default: current directory)
- `Format` (Optional): JSON, CSV, or HTML (default: JSON)

**Example:**
```powershell
$reportPath = Get-MigrationReport -DeviceType Windows -Format HTML
```

**Returns:** String path to report file

---

### Get-ComplianceReport

Generates a compliance status report.

**Parameters:**
- `PolicyId` (Optional): Specific compliance policy ID to report on
- `PolicyType` (Optional): Compliance or Configuration (default: Compliance)
- `DeviceType` (Optional): Filter by device type (default: All)
- `OutputPath` (Optional): Path to save the report

**Example:**
```powershell
$reportPath = Get-ComplianceReport -DeviceType Windows
```

**Returns:** String path to report file

---

### Export-PreMigrationReport

Exports a pre-migration baseline report.

**Parameters:**
- `DeviceType` (Optional): Device type to report on (default: All)
- `OutputPath` (Optional): Path to save the report

**Example:**
```powershell
$preReport = Export-PreMigrationReport -DeviceType Windows
```

**Returns:** String path to report file

---

### Export-PostMigrationReport

Exports a post-migration comparison report.

**Parameters:**
- `PreMigrationReportPath` (Required): Path to the pre-migration report for comparison
- `DeviceType` (Optional): Device type to report on (default: All)
- `OutputPath` (Optional): Path to save the report

**Example:**
```powershell
$postReport = Export-PostMigrationReport -PreMigrationReportPath $preReport -DeviceType Windows
```

**Returns:** String path to report file

---

## Graph API

### Connect-IntuneGraph

Connects to Microsoft Graph API with required Intune permissions.

**Parameters:**
- `Scopes` (Optional): Custom scopes to request
- `TenantId` (Optional): Azure AD Tenant ID
- `UseDeviceCode` (Optional): Use device code flow for authentication

**Example:**
```powershell
Connect-IntuneGraph
Connect-IntuneGraph -TenantId "contoso.onmicrosoft.com"
Connect-IntuneGraph -UseDeviceCode
```

**Returns:** Boolean indicating success

---

### Invoke-IntuneGraphRequest

Executes a Microsoft Graph API request with built-in retry logic.

**Parameters:**
- `Uri` (Required): The Graph API endpoint URI
- `Method` (Optional): GET, POST, PUT, PATCH, or DELETE (default: GET)
- `Body` (Optional): The request body for POST, PUT, or PATCH requests

**Example:**
```powershell
$result = Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" -Method GET
```

**Returns:** API response object

---

### Get-IntuneGraphData

Retrieves data from Microsoft Graph with OData query support.

**Parameters:**
- `Endpoint` (Required): The Graph API endpoint (e.g., "deviceManagement/managedDevices")
- `Filter` (Optional): OData $filter query string
- `Select` (Optional): OData $select query string
- `Expand` (Optional): OData $expand query string
- `ApiVersion` (Optional): v1.0 or beta (default: v1.0)

**Example:**
```powershell
$devices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices" -Filter "operatingSystem eq 'Windows'"
```

**Returns:** Array of objects from API

---

## Common Patterns

### Pattern: Complete Migration Workflow

```powershell
# 1. Connect
Connect-IntuneGraph

# 2. Validate
$readiness = Test-DeviceReadiness -DeviceType Windows
$licensing = Test-UserLicensing -GroupId "target-group"

# 3. Baseline
$preReport = Export-PreMigrationReport -DeviceType Windows

# 4. Backup
$rollback = New-RollbackPlan -PolicyIds @($policyId) -PolicyType Compliance

# 5. Pilot
$pilot = New-PilotGroup -GroupName "Migration-Pilot"
Test-PilotDeployment -PolicyId $policyId -PilotGroupId $pilot.id

# 6. Expand
Expand-PilotToProduction -PolicyId $policyId -ProductionGroupIds @($prodGroup)

# 7. Verify
$postReport = Export-PostMigrationReport -PreMigrationReportPath $preReport
```

### Pattern: Safe Policy Assignment

```powershell
# Backup first
$backup = Backup-PolicyConfiguration -PolicyId $policyId -PolicyType Configuration

# Assign
New-PolicyAssignment -PolicyId $policyId -PolicyType Configuration -GroupId $groupId

# Verify
$assignments = Get-PolicyAssignments -PolicyId $policyId -PolicyType Configuration

# If issues, rollback
Restore-PolicyConfiguration -BackupFile $backup
```

### Pattern: OData Filtering

```powershell
# Simple filter
$devices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices" -Filter "operatingSystem eq 'iOS'"

# Complex filter
$devices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows' and complianceState eq 'compliant'" `
    -Select "id,deviceName,userPrincipalName"

# With expansion
$devices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Expand "deviceCompliancePolicyStates" `
    -ApiVersion "beta"
```

---

## Error Handling

All functions include proper error handling. Example:

```powershell
try {
    $devices = Get-IntuneDevicesByScope -DeviceType Windows
}
catch {
    Write-Error "Failed to retrieve devices: $_"
    # Handle error
}
```

## Verbose Logging

Enable verbose output for troubleshooting:

```powershell
$VerbosePreference = 'Continue'
Get-IntuneDevicesByScope -DeviceType Windows
$VerbosePreference = 'SilentlyContinue'
```

## See Also

- [Getting Started Guide](./Getting-Started.md)
- [Graph API Guide](./GraphAPI-Guide.md)
- [Migration Best Practices](./Migration-Best-Practices.md)
- [Examples](../Examples/)

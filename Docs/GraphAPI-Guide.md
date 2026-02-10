# Graph API Integration Guide

## Overview

The IntuneScripts module provides comprehensive Microsoft Graph API integration with built-in support for:
- Automatic retry logic with exponential backoff
- Rate limiting and throttling handling
- OData query support ($filter, $select, $expand)
- Paging for large result sets
- Error handling and recovery

## Connection

### Basic Connection

```powershell
Connect-IntuneGraph
```

This connects with default scopes:
- DeviceManagementConfiguration.ReadWrite.All
- DeviceManagementManagedDevices.ReadWrite.All
- DeviceManagementApps.ReadWrite.All
- DeviceManagementServiceConfig.ReadWrite.All
- Group.ReadWrite.All
- Directory.Read.All

### Custom Scopes

```powershell
Connect-IntuneGraph -Scopes @(
    'DeviceManagementConfiguration.Read.All',
    'Group.Read.All'
)
```

### Device Code Flow

For non-interactive scenarios:

```powershell
Connect-IntuneGraph -UseDeviceCode
```

### Specific Tenant

```powershell
Connect-IntuneGraph -TenantId "contoso.onmicrosoft.com"
```

## Making API Requests

### Simple GET Request

```powershell
Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" -Method GET
```

### POST Request with Body

```powershell
$body = @{
    displayName = "My Policy"
    description = "Policy description"
}

Invoke-IntuneGraphRequest `
    -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies" `
    -Method POST `
    -Body $body
```

### PATCH Request

```powershell
$updateBody = @{
    displayName = "Updated Policy Name"
}

Invoke-IntuneGraphRequest `
    -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies/policy-id" `
    -Method PATCH `
    -Body $updateBody
```

## OData Queries

### Filtering

Get Windows devices:
```powershell
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows'"
```

Complex filters:
```powershell
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows' and complianceState eq 'compliant'"
```

Date-based filters:
```powershell
$cutoffDate = (Get-Date).AddDays(-7).ToString('yyyy-MM-dd')
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "lastSyncDateTime lt $cutoffDate"
```

### Selecting Fields

Limit returned fields:
```powershell
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Select "id,deviceName,operatingSystem,complianceState"
```

### Expanding Related Data

Get devices with related configuration states:
```powershell
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Expand "deviceConfigurationStates" `
    -ApiVersion "beta"
```

### Combining OData Queries

```powershell
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'iOS'" `
    -Select "id,deviceName,userPrincipalName" `
    -Expand "deviceCompliancePolicyStates"
```

## Rate Limiting and Retry Logic

The module automatically handles Graph API throttling:

### Automatic Retry

When a 429 (Too Many Requests) or 503 (Service Unavailable) error occurs:
1. The module waits according to the `Retry-After` header (if present)
2. If no `Retry-After` header, uses exponential backoff
3. Retries up to 5 times by default
4. Doubles the delay after each retry

### Monitoring Retries

Enable verbose output to see retry attempts:
```powershell
$VerbosePreference = 'Continue'
Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"
```

### Exponential Backoff Formula

```
Delay = InitialDelay * (2 ^ RetryCount)
```

Example delays:
- Retry 1: 1 second
- Retry 2: 2 seconds
- Retry 3: 4 seconds
- Retry 4: 8 seconds
- Retry 5: 16 seconds

## Paging

The module automatically handles paging for large result sets:

```powershell
# This will fetch all devices, even if there are thousands
$allDevices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"
```

The module follows `@odata.nextLink` until all pages are retrieved.

## Error Handling

### Connection Errors

```powershell
try {
    Connect-IntuneGraph
}
catch {
    Write-Error "Failed to connect: $_"
    # Handle connection failure
}
```

### API Request Errors

```powershell
try {
    $devices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Warning "Resource not found"
    }
    elseif ($_.Exception.Response.StatusCode -eq 403) {
        Write-Error "Insufficient permissions"
    }
    else {
        Write-Error "API request failed: $_"
    }
}
```

## Best Practices

### 1. Use OData Filtering

Instead of:
```powershell
# Don't do this - retrieves all devices then filters
$allDevices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"
$windowsDevices = $allDevices | Where-Object { $_.operatingSystem -eq 'Windows' }
```

Do this:
```powershell
# Better - filters on server side
$windowsDevices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows'"
```

### 2. Select Only Needed Fields

```powershell
# Only retrieve the fields you need
$devices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Select "id,deviceName,complianceState"
```

### 3. Handle Errors Gracefully

```powershell
$devices = @()
try {
    $devices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"
}
catch {
    Write-Warning "Failed to retrieve devices: $_"
    # Continue with empty array or alternative logic
}
```

### 4. Use Verbose Logging for Troubleshooting

```powershell
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'

# Run your commands
Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"

# Reset preferences
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'
```

### 5. Batch Operations

For bulk operations, use Graph batch API:
```powershell
# Process in batches to avoid overwhelming the API
$deviceIds = 1..1000
$batchSize = 20

for ($i = 0; $i -lt $deviceIds.Count; $i += $batchSize) {
    $batch = $deviceIds[$i..($i + $batchSize - 1)]
    
    foreach ($id in $batch) {
        # Process device
    }
    
    # Small delay between batches
    Start-Sleep -Milliseconds 100
}
```

## Common Graph API Endpoints

### Devices
- `deviceManagement/managedDevices` - All managed devices
- `deviceManagement/managedDevices/{id}` - Specific device
- `deviceManagement/managedDevices/{id}/deviceCompliancePolicyStates` - Device compliance

### Policies
- `deviceManagement/deviceCompliancePolicies` - Compliance policies
- `deviceManagement/deviceConfigurations` - Configuration policies
- `deviceAppManagement/iosManagedAppProtections` - iOS app protection
- `deviceAppManagement/mobileAppConfigurations` - App configurations

### Groups
- `groups` - All groups
- `groups/{id}` - Specific group
- `groups/{id}/members` - Group members

### Users
- `users` - All users
- `users/{id}` - Specific user
- `users/{id}/licenseDetails` - User licenses

## Troubleshooting

### Issue: "Not connected to Microsoft Graph"

**Solution:**
```powershell
Connect-IntuneGraph
```

### Issue: "Insufficient permissions"

**Solution:**
Reconnect with required scopes:
```powershell
Disconnect-MgGraph
Connect-IntuneGraph -Scopes @('DeviceManagementConfiguration.ReadWrite.All')
```

### Issue: Throttling/429 errors

**Solution:**
The module handles this automatically. If you see persistent throttling:
1. Reduce the frequency of requests
2. Use smaller batch sizes
3. Add delays between operations
4. Use OData filtering to reduce data volume

### Issue: Timeout errors

**Solution:**
```powershell
# For long-running operations, increase timeout (if supported)
# Or break into smaller batches
```

## Advanced Topics

### Using Beta API

Some features are only available in the beta API:
```powershell
Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -ApiVersion "beta"
```

### Custom Retry Logic

For special cases where you need different retry behavior, use the private function directly:
```powershell
# Advanced usage - not typically needed
Invoke-GraphRequestWithRetry `
    -Uri "https://graph.microsoft.com/v1.0/endpoint" `
    -Method GET `
    -MaxRetries 10 `
    -InitialDelaySeconds 2
```

## References

- [Microsoft Graph API Documentation](https://docs.microsoft.com/en-us/graph/api/overview)
- [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/en-us/powershell/microsoftgraph/)
- [OData Query Parameters](https://docs.microsoft.com/en-us/graph/query-parameters)
- [Graph API Throttling](https://docs.microsoft.com/en-us/graph/throttling)

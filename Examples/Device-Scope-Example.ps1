# Example: Device Scope and Filtering

# This example demonstrates how to use device scopes and OData filtering
# to target specific devices for management operations.

# Import the module
Import-Module .\IntuneScripts.psd1

# Connect to Graph
Connect-IntuneGraph

# Example 1: Get devices by type with compliance
Write-Host "Example 1: Get Windows devices with compliance status" -ForegroundColor Yellow
$windowsDevices = Get-IntuneDevicesByScope -DeviceType Windows -IncludeCompliance

Write-Host "Found $($windowsDevices.Count) Windows devices" -ForegroundColor Cyan
$windowsDevices | Select-Object -First 5 | ForEach-Object {
    Write-Host "  - $($_.deviceName): $($_.complianceState)" -ForegroundColor Cyan
}

# Example 2: Use custom OData filtering
Write-Host "`nExample 2: Get non-compliant iOS devices" -ForegroundColor Yellow
$nonCompliantIOS = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'iOS' and complianceState eq 'noncompliant'" `
    -Select "id,deviceName,complianceState,userPrincipalName"

Write-Host "Found $($nonCompliantIOS.Count) non-compliant iOS devices" -ForegroundColor Cyan

# Example 3: Get stale devices
Write-Host "`nExample 3: Get devices not synced in 30 days" -ForegroundColor Yellow
$staleDate = (Get-Date).AddDays(-30).ToString('yyyy-MM-dd')
$staleDevices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "lastSyncDateTime lt $staleDate" `
    -Select "id,deviceName,lastSyncDateTime,operatingSystem"

Write-Host "Found $($staleDevices.Count) stale devices" -ForegroundColor Red
$staleDevices | Select-Object -First 5 | ForEach-Object {
    Write-Host "  - $($_.deviceName) ($($_.operatingSystem)): Last sync $($_.lastSyncDateTime)" -ForegroundColor Red
}

# Example 4: Configure device scope for operations
Write-Host "`nExample 4: Configure device scope with group" -ForegroundColor Yellow
$scope = Set-DeviceScope `
    -DeviceType Windows,macOS `
    -GroupName "Corporate-Devices"

Write-Host "Device scope configured:" -ForegroundColor Green
Write-Host "  Device Types: $($scope.DeviceTypes -join ', ')" -ForegroundColor Cyan
if ($scope.GroupId) {
    Write-Host "  Group: $($scope.GroupName) ($($scope.GroupId))" -ForegroundColor Cyan
}

# Example 5: Get devices by multiple criteria
Write-Host "`nExample 5: Get managed Windows devices enrolled via AutoPilot" -ForegroundColor Yellow
$autopilotDevices = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows' and managementState eq 'managed' and deviceEnrollmentType eq 'windowsAzureADJoin'" `
    -Select "id,deviceName,serialNumber,enrolledDateTime"

Write-Host "Found $($autopilotDevices.Count) AutoPilot devices" -ForegroundColor Cyan

# Example 6: Using $expand to get related data
Write-Host "`nExample 6: Get devices with configuration states" -ForegroundColor Yellow
$devicesWithConfig = Get-IntuneGraphData `
    -Endpoint "deviceManagement/managedDevices" `
    -Filter "operatingSystem eq 'Windows'" `
    -Expand "deviceConfigurationStates" `
    -ApiVersion "beta"

Write-Host "Retrieved devices with expanded configuration states" -ForegroundColor Cyan

Write-Host "`nDevice scope and filtering examples complete!" -ForegroundColor Green

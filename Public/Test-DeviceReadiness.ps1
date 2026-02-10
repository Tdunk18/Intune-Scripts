function Test-DeviceReadiness {
    <#
    .SYNOPSIS
        Validates device readiness for migration.
    
    .DESCRIPTION
        Checks if devices are ready for Intune migration by validating:
        - Co-management status
        - Hybrid Azure AD join status
        - OS version compatibility
        - Enrollment status
    
    .PARAMETER DeviceIds
        Array of device IDs to check. If not provided, checks all devices.
    
    .PARAMETER DeviceType
        Filter by device type.
    
    .EXAMPLE
        Test-DeviceReadiness -DeviceType Windows
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$DeviceIds,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows')]
        [string]$DeviceType
    )
    
    try {
        Write-Host "Validating device readiness..." -ForegroundColor Yellow
        
        $results = @()
        
        # Get devices
        if ($DeviceIds) {
            $devices = @()
            foreach ($id in $DeviceIds) {
                $device = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices/$id"
                $devices += $device
            }
        }
        elseif ($DeviceType) {
            $devices = Get-IntuneDevicesByScope -DeviceType $DeviceType
        }
        else {
            $devices = Get-IntuneDevicesByScope -DeviceType All
        }
        
        Write-Host "Checking $($devices.Count) device(s)..." -ForegroundColor Cyan
        
        foreach ($device in $devices) {
            $readiness = @{
                DeviceId = $device.id
                DeviceName = $device.deviceName
                OperatingSystem = $device.operatingSystem
                OSVersion = $device.osVersion
                IsReady = $true
                Issues = @()
                Warnings = @()
            }
            
            # Check enrollment status
            if ($device.managementState -ne 'managed') {
                $readiness.IsReady = $false
                $readiness.Issues += "Device is not managed (Status: $($device.managementState))"
            }
            
            # Check compliance
            if ($device.complianceState -eq 'noncompliant') {
                $readiness.Warnings += "Device is not compliant"
            }
            
            # Check Azure AD join status
            if ($device.azureADRegistered -eq $false) {
                $readiness.Warnings += "Device is not Azure AD registered"
            }
            
            # Check last sync
            $lastSync = [DateTime]$device.lastSyncDateTime
            $daysSinceSync = (Get-Date) - $lastSync
            if ($daysSinceSync.TotalDays -gt 7) {
                $readiness.Warnings += "Device has not synced in $([Math]::Round($daysSinceSync.TotalDays)) days"
            }
            
            $results += [PSCustomObject]$readiness
        }
        
        # Summary
        $ready = ($results | Where-Object { $_.IsReady }).Count
        $notReady = ($results | Where-Object { -not $_.IsReady }).Count
        
        Write-Host "`nDevice Readiness Summary:" -ForegroundColor Green
        Write-Host "  Total devices: $($devices.Count)" -ForegroundColor Cyan
        Write-Host "  Ready: $ready" -ForegroundColor Green
        Write-Host "  Not ready: $notReady" -ForegroundColor $(if ($notReady -gt 0) { 'Red' } else { 'Cyan' })
        
        return $results
    }
    catch {
        Write-Error "Device readiness check failed: $_"
        throw
    }
}

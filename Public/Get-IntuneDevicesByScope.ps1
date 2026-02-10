function Get-IntuneDevicesByScope {
    <#
    .SYNOPSIS
        Retrieves Intune devices filtered by device type scope.
    
    .DESCRIPTION
        Fetches managed devices from Intune based on device type (iOS, Android, macOS, Windows).
        Supports multiple device types and returns detailed device information.
    
    .PARAMETER DeviceType
        One or more device types to filter by (iOS, Android, macOS, Windows).
    
    .PARAMETER IncludeCompliance
        Include compliance status information.
    
    .EXAMPLE
        Get-IntuneDevicesByScope -DeviceType Windows
    
    .EXAMPLE
        Get-IntuneDevicesByScope -DeviceType iOS,Android -IncludeCompliance
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows', 'All')]
        [string[]]$DeviceType,
        
        [Parameter(Mandatory = $false)]
        [switch]$IncludeCompliance
    )
    
    try {
        Write-Verbose "Retrieving devices for scope: $($DeviceType -join ', ')"
        
        $allDevices = @()
        
        # Build filter based on device types
        if ($DeviceType -contains 'All') {
            $devices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices"
        }
        else {
            foreach ($type in $DeviceType) {
                $filter = switch ($type) {
                    'iOS' { "operatingSystem eq 'iOS'" }
                    'Android' { "operatingSystem eq 'Android'" }
                    'macOS' { "operatingSystem eq 'macOS'" }
                    'Windows' { "operatingSystem eq 'Windows'" }
                }
                
                Write-Verbose "Fetching $type devices..."
                $devices = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices" -Filter $filter
                $allDevices += $devices
            }
            
            $devices = $allDevices
        }
        
        Write-Host "Retrieved $($devices.Count) device(s)" -ForegroundColor Green
        
        # Add compliance information if requested
        if ($IncludeCompliance) {
            Write-Verbose "Adding compliance information..."
            foreach ($device in $devices) {
                $complianceState = Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices/$($device.id)/deviceCompliancePolicyStates"
                $device | Add-Member -MemberType NoteProperty -Name 'ComplianceStates' -Value $complianceState -Force
            }
        }
        
        return $devices
    }
    catch {
        Write-Error "Failed to retrieve devices: $_"
        throw
    }
}

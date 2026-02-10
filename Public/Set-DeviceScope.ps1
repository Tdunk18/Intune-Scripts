function Set-DeviceScope {
    <#
    .SYNOPSIS
        Sets the device scope for subsequent operations.
    
    .DESCRIPTION
        Creates a scope configuration object that can be used to filter devices
        for policy assignments and other operations.
    
    .PARAMETER DeviceType
        Device types to include in scope.
    
    .PARAMETER GroupName
        Azure AD group name to scope devices to.
    
    .PARAMETER GroupId
        Azure AD group ID to scope devices to.
    
    .EXAMPLE
        $scope = Set-DeviceScope -DeviceType Windows,macOS
    
    .EXAMPLE
        $scope = Set-DeviceScope -DeviceType iOS -GroupName "iOS-Pilot-Users"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows', 'All')]
        [string[]]$DeviceType,
        
        [Parameter(Mandatory = $false)]
        [string]$GroupName,
        
        [Parameter(Mandatory = $false)]
        [string]$GroupId
    )
    
    $scopeConfig = @{
        DeviceTypes = $DeviceType
        Timestamp = Get-Date
    }
    
    if ($GroupName) {
        # Resolve group ID from name
        $group = Get-IntuneGraphData -Endpoint "groups" -Filter "displayName eq '$GroupName'"
        if ($group) {
            $scopeConfig['GroupId'] = $group[0].id
            $scopeConfig['GroupName'] = $GroupName
        }
        else {
            Write-Warning "Group '$GroupName' not found"
        }
    }
    elseif ($GroupId) {
        $scopeConfig['GroupId'] = $GroupId
    }
    
    Write-Host "Device scope configured:" -ForegroundColor Green
    Write-Host "  Device Types: $($DeviceType -join ', ')" -ForegroundColor Cyan
    if ($scopeConfig.GroupId) {
        Write-Host "  Group: $($scopeConfig.GroupName) ($($scopeConfig.GroupId))" -ForegroundColor Cyan
    }
    
    return [PSCustomObject]$scopeConfig
}

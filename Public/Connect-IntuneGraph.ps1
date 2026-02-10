function Connect-IntuneGraph {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph API with required Intune permissions.
    
    .DESCRIPTION
        Establishes a connection to Microsoft Graph API using the Microsoft.Graph PowerShell module.
        Requests appropriate scopes for Intune device and policy management.
    
    .PARAMETER Scopes
        Custom scopes to request. If not provided, uses default Intune scopes.
    
    .PARAMETER TenantId
        Azure AD Tenant ID.
    
    .PARAMETER UseDeviceCode
        Use device code flow for authentication.
    
    .EXAMPLE
        Connect-IntuneGraph
    
    .EXAMPLE
        Connect-IntuneGraph -TenantId "contoso.onmicrosoft.com"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Scopes,
        
        [Parameter(Mandatory = $false)]
        [string]$TenantId,
        
        [Parameter(Mandatory = $false)]
        [switch]$UseDeviceCode
    )
    
    # Default scopes for Intune management
    if (-not $Scopes) {
        $Scopes = @(
            'DeviceManagementConfiguration.ReadWrite.All',
            'DeviceManagementManagedDevices.ReadWrite.All',
            'DeviceManagementApps.ReadWrite.All',
            'DeviceManagementServiceConfig.ReadWrite.All',
            'Group.ReadWrite.All',
            'Directory.Read.All'
        )
    }
    
    try {
        $connectParams = @{
            Scopes = $Scopes
        }
        
        if ($TenantId) {
            $connectParams['TenantId'] = $TenantId
        }
        
        if ($UseDeviceCode) {
            $connectParams['UseDeviceCode'] = $true
        }
        
        Connect-MgGraph @connectParams -ErrorAction Stop
        
        $context = Get-MgContext
        Write-Host "Successfully connected to Microsoft Graph" -ForegroundColor Green
        Write-Host "Tenant: $($context.TenantId)" -ForegroundColor Cyan
        Write-Host "Account: $($context.Account)" -ForegroundColor Cyan
        Write-Host "Scopes: $($context.Scopes -join ', ')" -ForegroundColor Cyan
        
        return $true
    }
    catch {
        Write-Error "Failed to connect to Microsoft Graph: $_"
        return $false
    }
}

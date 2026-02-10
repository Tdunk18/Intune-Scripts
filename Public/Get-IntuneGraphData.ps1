function Get-IntuneGraphData {
    <#
    .SYNOPSIS
        Retrieves data from Microsoft Graph with OData query support.
    
    .DESCRIPTION
        Fetches data from Microsoft Graph API with support for OData queries ($filter, $select, $expand).
        Automatically handles paging to retrieve all results.
    
    .PARAMETER Endpoint
        The Graph API endpoint (e.g., "deviceManagement/managedDevices").
    
    .PARAMETER Filter
        OData $filter query string.
    
    .PARAMETER Select
        OData $select query string (comma-separated field names).
    
    .PARAMETER Expand
        OData $expand query string.
    
    .PARAMETER ApiVersion
        Graph API version (default: v1.0).
    
    .EXAMPLE
        Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices" -Filter "operatingSystem eq 'Windows'"
    
    .EXAMPLE
        Get-IntuneGraphData -Endpoint "deviceManagement/managedDevices" -Select "id,deviceName,operatingSystem" -Filter "operatingSystem eq 'iOS'"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        
        [Parameter(Mandatory = $false)]
        [string]$Filter,
        
        [Parameter(Mandatory = $false)]
        [string]$Select,
        
        [Parameter(Mandatory = $false)]
        [string]$Expand,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('v1.0', 'beta')]
        [string]$ApiVersion = 'v1.0'
    )
    
    try {
        # Verify connection
        $context = Get-MgContext
        if (-not $context) {
            throw "Not connected to Microsoft Graph. Please run Connect-IntuneGraph first."
        }
        
        # Build URI
        $uri = "https://graph.microsoft.com/$ApiVersion/$Endpoint"
        
        $params = @{
            Uri = $uri
        }
        
        if ($Filter) { $params['Filter'] = $Filter }
        if ($Select) { $params['Select'] = $Select }
        if ($Expand) { $params['Expand'] = $Expand }
        
        return Get-GraphDataWithPaging @params
    }
    catch {
        Write-Error "Failed to retrieve data from Graph API: $_"
        throw
    }
}

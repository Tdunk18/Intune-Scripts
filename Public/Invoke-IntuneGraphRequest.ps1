function Invoke-IntuneGraphRequest {
    <#
    .SYNOPSIS
        Executes a Microsoft Graph API request with built-in retry logic.
    
    .DESCRIPTION
        Wrapper function for making Graph API requests with automatic retry handling,
        exponential backoff, and error management.
    
    .PARAMETER Uri
        The Graph API endpoint URI.
    
    .PARAMETER Method
        The HTTP method (GET, POST, PUT, PATCH, DELETE).
    
    .PARAMETER Body
        The request body for POST, PUT, or PATCH requests.
    
    .EXAMPLE
        Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" -Method GET
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method = 'GET',
        
        [Parameter(Mandatory = $false)]
        [object]$Body
    )
    
    try {
        # Verify connection
        $context = Get-MgContext
        if (-not $context) {
            throw "Not connected to Microsoft Graph. Please run Connect-IntuneGraph first."
        }
        
        $params = @{
            Uri = $Uri
            Method = $Method
        }
        
        if ($Body) {
            $params['Body'] = $Body
        }
        
        return Invoke-GraphRequestWithRetry @params
    }
    catch {
        Write-Error "Graph API request failed: $_"
        throw
    }
}

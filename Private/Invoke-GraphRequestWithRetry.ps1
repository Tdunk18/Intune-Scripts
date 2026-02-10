function Invoke-GraphRequestWithRetry {
    <#
    .SYNOPSIS
        Executes a Graph API request with retry logic and exponential backoff.
    
    .DESCRIPTION
        Handles Graph API throttling by implementing retry logic with exponential backoff.
        Automatically retries on 429 (Too Many Requests) and 503 (Service Unavailable) errors.
    
    .PARAMETER Uri
        The Graph API endpoint URI.
    
    .PARAMETER Method
        The HTTP method (GET, POST, PUT, PATCH, DELETE).
    
    .PARAMETER Body
        The request body (for POST, PUT, PATCH requests).
    
    .PARAMETER MaxRetries
        Maximum number of retry attempts (default: 5).
    
    .PARAMETER InitialDelaySeconds
        Initial delay in seconds before first retry (default: 1).
    
    .EXAMPLE
        Invoke-GraphRequestWithRetry -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" -Method GET
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method = 'GET',
        
        [Parameter(Mandatory = $false)]
        [object]$Body,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 5,
        
        [Parameter(Mandatory = $false)]
        [int]$InitialDelaySeconds = 1
    )
    
    $retryCount = 0
    $delay = $InitialDelaySeconds
    
    while ($retryCount -le $MaxRetries) {
        try {
            $params = @{
                Uri = $Uri
                Method = $Method
            }
            
            if ($Body) {
                $params['Body'] = $Body | ConvertTo-Json -Depth 10
                $params['ContentType'] = 'application/json'
            }
            
            $response = Invoke-MgGraphRequest @params
            return $response
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            # Check if error is retryable (429 or 503)
            if ($statusCode -in @(429, 503) -and $retryCount -lt $MaxRetries) {
                $retryCount++
                
                # Check for Retry-After header
                $retryAfter = $_.Exception.Response.Headers['Retry-After']
                if ($retryAfter) {
                    $delay = [int]$retryAfter
                }
                
                Write-Warning "Graph API throttling detected (Status: $statusCode). Retry $retryCount of $MaxRetries after $delay seconds..."
                Start-Sleep -Seconds $delay
                
                # Exponential backoff
                $delay = $delay * 2
            }
            else {
                # Non-retryable error or max retries reached
                throw $_
            }
        }
    }
    
    throw "Max retries ($MaxRetries) exceeded for Graph API request to $Uri"
}

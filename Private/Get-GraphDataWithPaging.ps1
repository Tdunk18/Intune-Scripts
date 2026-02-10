function Get-GraphDataWithPaging {
    <#
    .SYNOPSIS
        Retrieves data from Graph API with automatic paging support.
    
    .DESCRIPTION
        Handles Graph API paging by following @odata.nextLink to retrieve all results.
    
    .PARAMETER Uri
        The Graph API endpoint URI.
    
    .PARAMETER Filter
        OData filter query.
    
    .PARAMETER Select
        OData select query.
    
    .PARAMETER Expand
        OData expand query.
    
    .EXAMPLE
        Get-GraphDataWithPaging -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" -Filter "operatingSystem eq 'Windows'"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $false)]
        [string]$Filter,
        
        [Parameter(Mandatory = $false)]
        [string]$Select,
        
        [Parameter(Mandatory = $false)]
        [string]$Expand
    )
    
    # Build query parameters
    $queryParams = @()
    if ($Filter) { $queryParams += "`$filter=$Filter" }
    if ($Select) { $queryParams += "`$select=$Select" }
    if ($Expand) { $queryParams += "`$expand=$Expand" }
    
    if ($queryParams.Count -gt 0) {
        $separator = if ($Uri -match '\?') { '&' } else { '?' }
        $Uri = "$Uri$separator$($queryParams -join '&')"
    }
    
    $allResults = @()
    $nextLink = $Uri
    
    do {
        $response = Invoke-GraphRequestWithRetry -Uri $nextLink -Method GET
        
        if ($response.value) {
            $allResults += $response.value
        }
        else {
            $allResults += $response
        }
        
        $nextLink = $response.'@odata.nextLink'
    } while ($nextLink)
    
    return $allResults
}

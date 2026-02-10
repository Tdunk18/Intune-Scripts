function Test-UserLicensing {
    <#
    .SYNOPSIS
        Validates user licensing for Intune.
    
    .DESCRIPTION
        Checks if users have the required Intune licenses assigned.
        Can check specific users or all users in specified groups.
    
    .PARAMETER UserIds
        Array of user IDs to check.
    
    .PARAMETER GroupId
        Check all users in a specific group.
    
    .PARAMETER RequiredSkuPartNumbers
        Required SKU part numbers (defaults to common Intune licenses).
    
    .EXAMPLE
        Test-UserLicensing -GroupId "group123"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$UserIds,
        
        [Parameter(Mandatory = $false)]
        [string]$GroupId,
        
        [Parameter(Mandatory = $false)]
        [string[]]$RequiredSkuPartNumbers = @('INTUNE_A', 'EMS', 'EMSPREMIUM', 'SPE_E3', 'SPE_E5')
    )
    
    try {
        Write-Host "Validating user licensing..." -ForegroundColor Yellow
        
        $results = @()
        $users = @()
        
        # Get users
        if ($UserIds) {
            foreach ($id in $UserIds) {
                $user = Get-IntuneGraphData -Endpoint "users/$id"
                $users += $user
            }
        }
        elseif ($GroupId) {
            $users = Get-IntuneGraphData -Endpoint "groups/$GroupId/members"
        }
        else {
            throw "Either UserIds or GroupId must be provided"
        }
        
        Write-Host "Checking $($users.Count) user(s)..." -ForegroundColor Cyan
        
        foreach ($user in $users) {
            # Get user's license details
            $licenses = Get-IntuneGraphData -Endpoint "users/$($user.id)/licenseDetails"
            
            $hasIntuneLicense = $false
            $assignedLicenses = @()
            
            foreach ($license in $licenses) {
                $assignedLicenses += $license.skuPartNumber
                if ($license.skuPartNumber -in $RequiredSkuPartNumbers) {
                    $hasIntuneLicense = $true
                }
            }
            
            $licenseCheck = @{
                UserId = $user.id
                UserPrincipalName = $user.userPrincipalName
                DisplayName = $user.displayName
                HasIntuneLicense = $hasIntuneLicense
                AssignedLicenses = $assignedLicenses
            }
            
            $results += [PSCustomObject]$licenseCheck
        }
        
        # Summary
        $licensed = ($results | Where-Object { $_.HasIntuneLicense }).Count
        $unlicensed = ($results | Where-Object { -not $_.HasIntuneLicense }).Count
        
        Write-Host "`nUser Licensing Summary:" -ForegroundColor Green
        Write-Host "  Total users: $($users.Count)" -ForegroundColor Cyan
        Write-Host "  Licensed: $licensed" -ForegroundColor Green
        Write-Host "  Unlicensed: $unlicensed" -ForegroundColor $(if ($unlicensed -gt 0) { 'Red' } else { 'Cyan' })
        
        if ($unlicensed -gt 0) {
            Write-Warning "The following users do not have Intune licenses:"
            $results | Where-Object { -not $_.HasIntuneLicense } | ForEach-Object {
                Write-Warning "  - $($_.UserPrincipalName)"
            }
        }
        
        return $results
    }
    catch {
        Write-Error "User licensing check failed: $_"
        throw
    }
}

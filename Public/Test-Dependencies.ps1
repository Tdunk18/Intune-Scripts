function Test-Dependencies {
    <#
    .SYNOPSIS
        Validates policy and app dependencies.
    
    .DESCRIPTION
        Checks for dependencies between policies, apps, and configurations.
        Identifies missing prerequisites and potential conflicts.
    
    .PARAMETER PolicyId
        The policy ID to check dependencies for.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .EXAMPLE
        Test-Dependencies -PolicyId "abc123" -PolicyType Configuration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType
    )
    
    try {
        Write-Host "Checking dependencies for policy $PolicyId..." -ForegroundColor Yellow
        
        $dependencies = @{
            PolicyId = $PolicyId
            PolicyType = $PolicyType
            Prerequisites = @()
            Conflicts = @()
            Warnings = @()
            IsValid = $true
        }
        
        # Get policy details
        $policyEndpoint = switch ($PolicyType) {
            'Compliance' { "deviceManagement/deviceCompliancePolicies/$PolicyId" }
            'Configuration' { "deviceManagement/deviceConfigurations/$PolicyId" }
            'AppProtection' { "deviceAppManagement/iosManagedAppProtections/$PolicyId" }
            'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations/$PolicyId" }
        }
        
        $policy = Get-IntuneGraphData -Endpoint $policyEndpoint
        
        # Check for app-based dependencies
        if ($PolicyType -eq 'AppConfiguration' -or $PolicyType -eq 'AppProtection') {
            if ($policy.targetedAppManagementLevels) {
                $dependencies.Prerequisites += "Managed apps must be deployed"
            }
            
            if ($policy.apps) {
                foreach ($app in $policy.apps) {
                    # Check if app exists
                    try {
                        $appDetails = Get-IntuneGraphData -Endpoint "deviceAppManagement/mobileApps/$($app.mobileAppIdentifier.bundleId)"
                        if (-not $appDetails) {
                            $dependencies.IsValid = $false
                            $dependencies.Prerequisites += "Required app not found: $($app.mobileAppIdentifier.bundleId)"
                        }
                    }
                    catch {
                        $dependencies.Warnings += "Could not verify app: $($app.mobileAppIdentifier.bundleId)"
                    }
                }
            }
        }
        
        # Check for conflicting assignments
        $assignments = Get-PolicyAssignments -PolicyId $PolicyId -PolicyType $PolicyType
        if ($assignments.Count -gt 0) {
            # Get other policies of same type
            $allPoliciesEndpoint = switch ($PolicyType) {
                'Compliance' { "deviceManagement/deviceCompliancePolicies" }
                'Configuration' { "deviceManagement/deviceConfigurations" }
                'AppProtection' { "deviceAppManagement/iosManagedAppProtections" }
                'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations" }
            }
            
            $allPolicies = Get-IntuneGraphData -Endpoint $allPoliciesEndpoint
            foreach ($otherPolicy in $allPolicies) {
                if ($otherPolicy.id -ne $PolicyId) {
                    $otherAssignments = Get-PolicyAssignments -PolicyId $otherPolicy.id -PolicyType $PolicyType
                    
                    # Check for overlapping group assignments
                    foreach ($assignment in $assignments) {
                        foreach ($otherAssignment in $otherAssignments) {
                            if ($assignment.target.groupId -eq $otherAssignment.target.groupId) {
                                $dependencies.Warnings += "Overlapping assignment with policy $($otherPolicy.displayName) on group $($assignment.target.groupId)"
                            }
                        }
                    }
                }
            }
        }
        
        # Summary
        Write-Host "`nDependency Check Results:" -ForegroundColor Green
        Write-Host "  Policy: $($policy.displayName)" -ForegroundColor Cyan
        Write-Host "  Valid: $($dependencies.IsValid)" -ForegroundColor $(if ($dependencies.IsValid) { 'Green' } else { 'Red' })
        Write-Host "  Prerequisites: $($dependencies.Prerequisites.Count)" -ForegroundColor Cyan
        Write-Host "  Warnings: $($dependencies.Warnings.Count)" -ForegroundColor $(if ($dependencies.Warnings.Count -gt 0) { 'Yellow' } else { 'Cyan' })
        
        if ($dependencies.Prerequisites.Count -gt 0) {
            Write-Host "`nPrerequisites:" -ForegroundColor Yellow
            $dependencies.Prerequisites | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        }
        
        if ($dependencies.Warnings.Count -gt 0) {
            Write-Host "`nWarnings:" -ForegroundColor Yellow
            $dependencies.Warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        }
        
        return [PSCustomObject]$dependencies
    }
    catch {
        Write-Error "Dependency check failed: $_"
        throw
    }
}

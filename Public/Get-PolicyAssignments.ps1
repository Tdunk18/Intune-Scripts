function Get-PolicyAssignments {
    <#
    .SYNOPSIS
        Retrieves policy assignments from Intune.
    
    .DESCRIPTION
        Gets all assignments for a specific policy or all policies of a given type.
    
    .PARAMETER PolicyId
        The ID of the policy to get assignments for.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .EXAMPLE
        Get-PolicyAssignments -PolicyId "abc123" -PolicyType Compliance
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
        $endpoint = switch ($PolicyType) {
            'Compliance' { "deviceManagement/deviceCompliancePolicies/$PolicyId/assignments" }
            'Configuration' { "deviceManagement/deviceConfigurations/$PolicyId/assignments" }
            'AppProtection' { "deviceAppManagement/iosManagedAppProtections/$PolicyId/assignments" }
            'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations/$PolicyId/assignments" }
        }
        
        $assignments = Get-IntuneGraphData -Endpoint $endpoint
        
        Write-Host "Retrieved $($assignments.Count) assignment(s) for policy $PolicyId" -ForegroundColor Green
        
        return $assignments
    }
    catch {
        Write-Error "Failed to retrieve policy assignments: $_"
        throw
    }
}

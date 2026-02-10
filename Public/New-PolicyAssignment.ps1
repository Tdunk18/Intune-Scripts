function New-PolicyAssignment {
    <#
    .SYNOPSIS
        Creates a new policy assignment in Intune.
    
    .DESCRIPTION
        Assigns a compliance, configuration, or app protection policy to specified groups.
        Supports different policy types and assignment configurations.
    
    .PARAMETER PolicyId
        The ID of the policy to assign.
    
    .PARAMETER PolicyType
        The type of policy (Compliance, Configuration, AppProtection).
    
    .PARAMETER GroupId
        The Azure AD group ID to assign the policy to.
    
    .PARAMETER AssignmentType
        The assignment type (Include, Exclude).
    
    .EXAMPLE
        New-PolicyAssignment -PolicyId "abc123" -PolicyType Compliance -GroupId "group123" -AssignmentType Include
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType,
        
        [Parameter(Mandatory = $true)]
        [string]$GroupId,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Include', 'Exclude')]
        [string]$AssignmentType = 'Include'
    )
    
    try {
        # Determine the endpoint based on policy type
        $endpoint = switch ($PolicyType) {
            'Compliance' { "deviceManagement/deviceCompliancePolicies/$PolicyId/assignments" }
            'Configuration' { "deviceManagement/deviceConfigurations/$PolicyId/assignments" }
            'AppProtection' { "deviceAppManagement/iosManagedAppProtections/$PolicyId/assignments" }
            'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations/$PolicyId/assignments" }
        }
        
        # Build assignment object
        $assignment = @{
            target = @{
                '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                groupId = $GroupId
            }
        }
        
        if ($AssignmentType -eq 'Exclude') {
            $assignment.target.'@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
        }
        
        if ($PSCmdlet.ShouldProcess("Policy $PolicyId", "Create assignment for group $GroupId")) {
            $result = Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/$endpoint" -Method POST -Body $assignment
            
            Write-Host "Successfully created policy assignment" -ForegroundColor Green
            Write-Host "  Policy ID: $PolicyId" -ForegroundColor Cyan
            Write-Host "  Policy Type: $PolicyType" -ForegroundColor Cyan
            Write-Host "  Group ID: $GroupId" -ForegroundColor Cyan
            Write-Host "  Assignment Type: $AssignmentType" -ForegroundColor Cyan
            
            return $result
        }
    }
    catch {
        Write-Error "Failed to create policy assignment: $_"
        throw
    }
}

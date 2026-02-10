function Set-PolicyAssignment {
    <#
    .SYNOPSIS
        Updates an existing policy assignment.
    
    .DESCRIPTION
        Modifies an existing policy assignment in Intune.
    
    .PARAMETER PolicyId
        The ID of the policy.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .PARAMETER AssignmentId
        The ID of the assignment to update.
    
    .PARAMETER GroupId
        The new group ID for the assignment.
    
    .EXAMPLE
        Set-PolicyAssignment -PolicyId "abc123" -PolicyType Compliance -AssignmentId "assign123" -GroupId "newgroup123"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType,
        
        [Parameter(Mandatory = $true)]
        [string]$AssignmentId,
        
        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )
    
    try {
        $endpoint = switch ($PolicyType) {
            'Compliance' { "deviceManagement/deviceCompliancePolicies/$PolicyId/assignments/$AssignmentId" }
            'Configuration' { "deviceManagement/deviceConfigurations/$PolicyId/assignments/$AssignmentId" }
            'AppProtection' { "deviceAppManagement/iosManagedAppProtections/$PolicyId/assignments/$AssignmentId" }
            'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations/$PolicyId/assignments/$AssignmentId" }
        }
        
        $assignment = @{
            target = @{
                '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                groupId = $GroupId
            }
        }
        
        if ($PSCmdlet.ShouldProcess("Assignment $AssignmentId", "Update policy assignment")) {
            $result = Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/$endpoint" -Method PATCH -Body $assignment
            
            Write-Host "Successfully updated policy assignment" -ForegroundColor Green
            
            return $result
        }
    }
    catch {
        Write-Error "Failed to update policy assignment: $_"
        throw
    }
}

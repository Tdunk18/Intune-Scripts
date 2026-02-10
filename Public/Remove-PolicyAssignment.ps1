function Remove-PolicyAssignment {
    <#
    .SYNOPSIS
        Removes a policy assignment from Intune.
    
    .DESCRIPTION
        Deletes a policy assignment for a specified policy.
    
    .PARAMETER PolicyId
        The ID of the policy.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .PARAMETER AssignmentId
        The ID of the assignment to remove.
    
    .EXAMPLE
        Remove-PolicyAssignment -PolicyId "abc123" -PolicyType Compliance -AssignmentId "assign123"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType,
        
        [Parameter(Mandatory = $true)]
        [string]$AssignmentId
    )
    
    try {
        $endpoint = switch ($PolicyType) {
            'Compliance' { "deviceManagement/deviceCompliancePolicies/$PolicyId/assignments/$AssignmentId" }
            'Configuration' { "deviceManagement/deviceConfigurations/$PolicyId/assignments/$AssignmentId" }
            'AppProtection' { "deviceAppManagement/iosManagedAppProtections/$PolicyId/assignments/$AssignmentId" }
            'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations/$PolicyId/assignments/$AssignmentId" }
        }
        
        if ($PSCmdlet.ShouldProcess("Assignment $AssignmentId", "Remove policy assignment")) {
            Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/$endpoint" -Method DELETE
            
            Write-Host "Successfully removed policy assignment $AssignmentId" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to remove policy assignment: $_"
        throw
    }
}

function Expand-PilotToProduction {
    <#
    .SYNOPSIS
        Expands a pilot deployment to production groups.
    
    .DESCRIPTION
        After successful pilot testing, expands the policy assignment to production groups.
        Can optionally remove the pilot group assignment.
    
    .PARAMETER PolicyId
        The ID of the policy to expand.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .PARAMETER ProductionGroupIds
        Array of production group IDs to assign the policy to.
    
    .PARAMETER RemovePilotAssignment
        Remove the pilot group assignment after expanding to production.
    
    .PARAMETER PilotGroupId
        The pilot group ID (required if RemovePilotAssignment is specified).
    
    .EXAMPLE
        Expand-PilotToProduction -PolicyId "abc123" -PolicyType Compliance -ProductionGroupIds @("prod1", "prod2")
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType,
        
        [Parameter(Mandatory = $true)]
        [string[]]$ProductionGroupIds,
        
        [Parameter(Mandatory = $false)]
        [switch]$RemovePilotAssignment,
        
        [Parameter(Mandatory = $false)]
        [string]$PilotGroupId
    )
    
    try {
        Write-Host "Expanding pilot deployment to production..." -ForegroundColor Yellow
        
        $results = @()
        
        # Assign to production groups
        foreach ($groupId in $ProductionGroupIds) {
            if ($PSCmdlet.ShouldProcess($groupId, "Assign policy to production group")) {
                Write-Host "Assigning policy to production group $groupId..." -ForegroundColor Cyan
                $assignment = New-PolicyAssignment -PolicyId $PolicyId -PolicyType $PolicyType -GroupId $groupId -AssignmentType Include
                $results += $assignment
            }
        }
        
        # Optionally remove pilot assignment
        if ($RemovePilotAssignment -and $PilotGroupId) {
            if ($PSCmdlet.ShouldProcess($PilotGroupId, "Remove pilot group assignment")) {
                Write-Host "Removing pilot group assignment..." -ForegroundColor Cyan
                $pilotAssignments = Get-PolicyAssignments -PolicyId $PolicyId -PolicyType $PolicyType
                $pilotAssignment = $pilotAssignments | Where-Object { $_.target.groupId -eq $PilotGroupId }
                
                if ($pilotAssignment) {
                    Remove-PolicyAssignment -PolicyId $PolicyId -PolicyType $PolicyType -AssignmentId $pilotAssignment.id
                }
            }
        }
        
        Write-Host "`nSuccessfully expanded to production" -ForegroundColor Green
        Write-Host "  Production groups: $($ProductionGroupIds.Count)" -ForegroundColor Cyan
        
        return $results
    }
    catch {
        Write-Error "Failed to expand pilot to production: $_"
        throw
    }
}

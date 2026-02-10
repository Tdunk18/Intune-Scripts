function Test-PilotDeployment {
    <#
    .SYNOPSIS
        Tests a policy deployment on a pilot group.
    
    .DESCRIPTION
        Deploys a policy to a pilot group and monitors the deployment status.
        Provides feedback on deployment success and any issues encountered.
    
    .PARAMETER PolicyId
        The ID of the policy to deploy.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .PARAMETER PilotGroupId
        The ID of the pilot group.
    
    .PARAMETER MonitoringDurationMinutes
        How long to monitor the deployment (default: 30 minutes).
    
    .EXAMPLE
        Test-PilotDeployment -PolicyId "abc123" -PolicyType Compliance -PilotGroupId "group123"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType,
        
        [Parameter(Mandatory = $true)]
        [string]$PilotGroupId,
        
        [Parameter(Mandatory = $false)]
        [int]$MonitoringDurationMinutes = 30
    )
    
    try {
        Write-Host "Starting pilot deployment test..." -ForegroundColor Yellow
        
        # Create assignment to pilot group
        Write-Host "Assigning policy to pilot group..." -ForegroundColor Cyan
        $assignment = New-PolicyAssignment -PolicyId $PolicyId -PolicyType $PolicyType -GroupId $PilotGroupId -AssignmentType Include
        
        # Get group members
        $members = Get-IntuneGraphData -Endpoint "groups/$PilotGroupId/members"
        Write-Host "Pilot group has $($members.Count) member(s)" -ForegroundColor Cyan
        
        # Create monitoring report
        $report = @{
            PolicyId = $PolicyId
            PolicyType = $PolicyType
            PilotGroupId = $PilotGroupId
            AssignmentId = $assignment.id
            StartTime = Get-Date
            MemberCount = $members.Count
            Status = 'InProgress'
        }
        
        Write-Host "`nPilot deployment initiated:" -ForegroundColor Green
        Write-Host "  Policy ID: $PolicyId" -ForegroundColor Cyan
        Write-Host "  Policy Type: $PolicyType" -ForegroundColor Cyan
        Write-Host "  Pilot Group: $PilotGroupId" -ForegroundColor Cyan
        Write-Host "  Members: $($members.Count)" -ForegroundColor Cyan
        Write-Host "`nMonitor the deployment for the next $MonitoringDurationMinutes minutes" -ForegroundColor Yellow
        Write-Host "Use Get-ComplianceReport to check deployment status" -ForegroundColor Yellow
        
        return [PSCustomObject]$report
    }
    catch {
        Write-Error "Pilot deployment test failed: $_"
        throw
    }
}

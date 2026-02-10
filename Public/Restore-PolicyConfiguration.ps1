function Restore-PolicyConfiguration {
    <#
    .SYNOPSIS
        Restores a policy configuration from a backup file.
    
    .DESCRIPTION
        Restores policy assignments from a backup file created by Backup-PolicyConfiguration.
        Can optionally restore the policy settings as well.
    
    .PARAMETER BackupFile
        Path to the backup JSON file.
    
    .PARAMETER RestoreAssignmentsOnly
        Only restore assignments, not policy settings.
    
    .EXAMPLE
        Restore-PolicyConfiguration -BackupFile "PolicyBackup_Compliance_abc123_20260210-120000.json"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$BackupFile,
        
        [Parameter(Mandatory = $false)]
        [switch]$RestoreAssignmentsOnly
    )
    
    try {
        Write-Host "Restoring policy configuration from backup..." -ForegroundColor Yellow
        
        # Read backup file
        $backup = Get-Content -Path $BackupFile -Raw | ConvertFrom-Json
        
        Write-Host "Backup details:" -ForegroundColor Cyan
        Write-Host "  Backup Date: $($backup.BackupDate)" -ForegroundColor Cyan
        Write-Host "  Policy ID: $($backup.PolicyId)" -ForegroundColor Cyan
        Write-Host "  Policy Type: $($backup.PolicyType)" -ForegroundColor Cyan
        Write-Host "  Assignments: $($backup.Assignments.Count)" -ForegroundColor Cyan
        
        if ($PSCmdlet.ShouldProcess($backup.PolicyId, "Restore policy configuration")) {
            # Get current assignments
            $currentAssignments = Get-PolicyAssignments -PolicyId $backup.PolicyId -PolicyType $backup.PolicyType
            
            # Remove current assignments
            Write-Host "Removing current assignments..." -ForegroundColor Yellow
            foreach ($assignment in $currentAssignments) {
                Remove-PolicyAssignment -PolicyId $backup.PolicyId -PolicyType $backup.PolicyType -AssignmentId $assignment.id -Confirm:$false
            }
            
            # Restore assignments from backup
            Write-Host "Restoring assignments from backup..." -ForegroundColor Yellow
            foreach ($assignment in $backup.Assignments) {
                if ($assignment.target.groupId) {
                    $assignmentType = if ($assignment.target.'@odata.type' -like '*exclusion*') { 'Exclude' } else { 'Include' }
                    New-PolicyAssignment -PolicyId $backup.PolicyId -PolicyType $backup.PolicyType -GroupId $assignment.target.groupId -AssignmentType $assignmentType -Confirm:$false
                }
            }
            
            Write-Host "`nRestore completed successfully" -ForegroundColor Green
            Write-Host "  Policy ID: $($backup.PolicyId)" -ForegroundColor Cyan
            Write-Host "  Assignments restored: $($backup.Assignments.Count)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Error "Failed to restore policy configuration: $_"
        throw
    }
}

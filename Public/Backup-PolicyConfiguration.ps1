function Backup-PolicyConfiguration {
    <#
    .SYNOPSIS
        Backs up a policy configuration for rollback purposes.
    
    .DESCRIPTION
        Creates a backup of policy settings and assignments that can be used for rollback.
        Exports the configuration to a JSON file.
    
    .PARAMETER PolicyId
        The ID of the policy to backup.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .PARAMETER BackupPath
        Path to save the backup file (defaults to current directory).
    
    .EXAMPLE
        Backup-PolicyConfiguration -PolicyId "abc123" -PolicyType Compliance
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compliance', 'Configuration', 'AppProtection', 'AppConfiguration')]
        [string]$PolicyType,
        
        [Parameter(Mandatory = $false)]
        [string]$BackupPath = "."
    )
    
    try {
        Write-Host "Backing up policy configuration..." -ForegroundColor Yellow
        
        # Get policy details
        $policyEndpoint = switch ($PolicyType) {
            'Compliance' { "deviceManagement/deviceCompliancePolicies/$PolicyId" }
            'Configuration' { "deviceManagement/deviceConfigurations/$PolicyId" }
            'AppProtection' { "deviceAppManagement/iosManagedAppProtections/$PolicyId" }
            'AppConfiguration' { "deviceAppManagement/mobileAppConfigurations/$PolicyId" }
        }
        
        $policy = Get-IntuneGraphData -Endpoint $policyEndpoint
        
        # Get assignments
        $assignments = Get-PolicyAssignments -PolicyId $PolicyId -PolicyType $PolicyType
        
        # Create backup object
        $backup = @{
            BackupDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            PolicyId = $PolicyId
            PolicyType = $PolicyType
            Policy = $policy
            Assignments = $assignments
        }
        
        # Generate filename
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $filename = "PolicyBackup_$($PolicyType)_$($PolicyId)_$timestamp.json"
        $fullPath = Join-Path $BackupPath $filename
        
        # Export to JSON
        $backup | ConvertTo-Json -Depth 10 | Out-File -FilePath $fullPath -Encoding UTF8
        
        Write-Host "Backup completed successfully" -ForegroundColor Green
        Write-Host "  Backup file: $fullPath" -ForegroundColor Cyan
        Write-Host "  Policy ID: $PolicyId" -ForegroundColor Cyan
        Write-Host "  Assignments backed up: $($assignments.Count)" -ForegroundColor Cyan
        
        return $fullPath
    }
    catch {
        Write-Error "Failed to backup policy configuration: $_"
        throw
    }
}

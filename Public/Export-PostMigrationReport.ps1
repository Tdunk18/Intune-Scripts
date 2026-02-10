function Export-PostMigrationReport {
    <#
    .SYNOPSIS
        Exports a post-migration comparison report.
    
    .DESCRIPTION
        Creates a comprehensive report after migration comparing results to the baseline.
        Highlights changes, issues, and migration success metrics.
    
    .PARAMETER PreMigrationReportPath
        Path to the pre-migration report for comparison.
    
    .PARAMETER DeviceType
        Device type to report on.
    
    .PARAMETER OutputPath
        Path to save the report.
    
    .EXAMPLE
        Export-PostMigrationReport -PreMigrationReportPath "PreMigrationReport_Windows_20260210-120000.json"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$PreMigrationReportPath,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows', 'All')]
        [string]$DeviceType = 'All',
        
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = "."
    )
    
    try {
        Write-Host "Generating post-migration comparison report..." -ForegroundColor Yellow
        
        # Load pre-migration report
        Write-Host "Loading pre-migration baseline..." -ForegroundColor Cyan
        $preMigrationReport = Get-Content -Path $PreMigrationReportPath -Raw | ConvertFrom-Json
        
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        
        # Get current state
        Write-Host "Gathering current device state..." -ForegroundColor Cyan
        $currentDevices = if ($DeviceType -eq 'All') {
            Get-IntuneDevicesByScope -DeviceType All -IncludeCompliance
        } else {
            Get-IntuneDevicesByScope -DeviceType $DeviceType -IncludeCompliance
        }
        
        # Run post-migration checks
        Write-Host "Running post-migration checks..." -ForegroundColor Cyan
        $deviceReadiness = Test-DeviceReadiness -DeviceType $DeviceType
        
        # Build comparison report
        $report = @{
            ReportType = 'PostMigration'
            GeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            PreMigrationReportDate = $preMigrationReport.GeneratedDate
            DeviceType = $DeviceType
            Comparison = @{
                PreMigration = @{
                    TotalDevices = $preMigrationReport.TotalDevices
                    ReadyDevices = $preMigrationReport.ReadyDevices
                }
                PostMigration = @{
                    TotalDevices = $currentDevices.Count
                    ReadyDevices = ($deviceReadiness | Where-Object { $_.IsReady }).Count
                }
                Changes = @{
                    DevicesDelta = $currentDevices.Count - $preMigrationReport.TotalDevices
                    ReadyDelta = (($deviceReadiness | Where-Object { $_.IsReady }).Count) - $preMigrationReport.ReadyDevices
                }
            }
            CurrentState = @{
                Devices = $currentDevices
                DeviceReadiness = $deviceReadiness
            }
            Issues = @()
            SuccessRate = 0
        }
        
        # Calculate success rate
        if ($preMigrationReport.TotalDevices -gt 0) {
            $migratedSuccessfully = ($deviceReadiness | Where-Object { $_.IsReady }).Count
            $report.SuccessRate = [Math]::Round(($migratedSuccessfully / $preMigrationReport.TotalDevices) * 100, 2)
        }
        
        # Identify issues
        $notReadyDevices = $deviceReadiness | Where-Object { -not $_.IsReady }
        foreach ($device in $notReadyDevices) {
            $report.Issues += @{
                DeviceId = $device.DeviceId
                DeviceName = $device.DeviceName
                Issues = $device.Issues
            }
        }
        
        # Generate filename
        $filename = "PostMigrationReport_$($DeviceType)_$timestamp.json"
        $fullPath = Join-Path $OutputPath $filename
        
        # Export to JSON
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $fullPath -Encoding UTF8
        
        Write-Host "`nPost-Migration Report Summary:" -ForegroundColor Green
        Write-Host "  Migration Success Rate: $($report.SuccessRate)%" -ForegroundColor $(if ($report.SuccessRate -ge 90) { 'Green' } elseif ($report.SuccessRate -ge 70) { 'Yellow' } else { 'Red' })
        Write-Host "`nDevice Comparison:" -ForegroundColor Cyan
        Write-Host "  Pre-Migration Total: $($report.Comparison.PreMigration.TotalDevices)" -ForegroundColor Cyan
        Write-Host "  Post-Migration Total: $($report.Comparison.PostMigration.TotalDevices)" -ForegroundColor Cyan
        Write-Host "  Change: $($report.Comparison.Changes.DevicesDelta)" -ForegroundColor Cyan
        Write-Host "`nReadiness Comparison:" -ForegroundColor Cyan
        Write-Host "  Pre-Migration Ready: $($report.Comparison.PreMigration.ReadyDevices)" -ForegroundColor Cyan
        Write-Host "  Post-Migration Ready: $($report.Comparison.PostMigration.ReadyDevices)" -ForegroundColor Cyan
        Write-Host "  Change: $($report.Comparison.Changes.ReadyDelta)" -ForegroundColor Cyan
        
        if ($report.Issues.Count -gt 0) {
            Write-Host "`nIssues Found: $($report.Issues.Count)" -ForegroundColor Red
        }
        
        Write-Host "`nReport saved to: $fullPath" -ForegroundColor Cyan
        
        return $fullPath
    }
    catch {
        Write-Error "Failed to generate post-migration report: $_"
        throw
    }
}

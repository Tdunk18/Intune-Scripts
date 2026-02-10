function Export-PreMigrationReport {
    <#
    .SYNOPSIS
        Exports a pre-migration baseline report.
    
    .DESCRIPTION
        Creates a comprehensive baseline report before migration begins.
        Captures current state for comparison after migration.
    
    .PARAMETER DeviceType
        Device type to report on.
    
    .PARAMETER OutputPath
        Path to save the report.
    
    .EXAMPLE
        Export-PreMigrationReport -DeviceType Windows
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows', 'All')]
        [string]$DeviceType = 'All',
        
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = "."
    )
    
    try {
        Write-Host "Generating pre-migration baseline report..." -ForegroundColor Yellow
        
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        
        # Run all validation checks
        Write-Host "Checking device readiness..." -ForegroundColor Cyan
        $deviceReadiness = Test-DeviceReadiness -DeviceType $DeviceType
        
        # Get current device inventory
        Write-Host "Gathering device inventory..." -ForegroundColor Cyan
        $devices = if ($DeviceType -eq 'All') {
            Get-IntuneDevicesByScope -DeviceType All -IncludeCompliance
        } else {
            Get-IntuneDevicesByScope -DeviceType $DeviceType -IncludeCompliance
        }
        
        # Build comprehensive report
        $report = @{
            ReportType = 'PreMigration'
            GeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            DeviceType = $DeviceType
            DeviceReadiness = $deviceReadiness
            TotalDevices = $devices.Count
            ReadyDevices = ($deviceReadiness | Where-Object { $_.IsReady }).Count
            NotReadyDevices = ($deviceReadiness | Where-Object { -not $_.IsReady }).Count
            Devices = $devices
        }
        
        # Generate filename
        $filename = "PreMigrationReport_$($DeviceType)_$timestamp.json"
        $fullPath = Join-Path $OutputPath $filename
        
        # Export to JSON
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $fullPath -Encoding UTF8
        
        Write-Host "`nPre-Migration Report Summary:" -ForegroundColor Green
        Write-Host "  Total Devices: $($report.TotalDevices)" -ForegroundColor Cyan
        Write-Host "  Ready for Migration: $($report.ReadyDevices)" -ForegroundColor Green
        Write-Host "  Not Ready: $($report.NotReadyDevices)" -ForegroundColor $(if ($report.NotReadyDevices -gt 0) { 'Red' } else { 'Cyan' })
        Write-Host "`nReport saved to: $fullPath" -ForegroundColor Cyan
        
        return $fullPath
    }
    catch {
        Write-Error "Failed to generate pre-migration report: $_"
        throw
    }
}

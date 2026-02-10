function Get-ComplianceReport {
    <#
    .SYNOPSIS
        Generates a compliance status report.
    
    .DESCRIPTION
        Creates a detailed report of device compliance status.
    
    .PARAMETER PolicyId
        Specific compliance policy ID to report on.
    
    .PARAMETER PolicyType
        The type of policy.
    
    .PARAMETER DeviceType
        Filter by device type.
    
    .PARAMETER OutputPath
        Path to save the report.
    
    .EXAMPLE
        Get-ComplianceReport -DeviceType Windows
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$PolicyId,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Compliance', 'Configuration')]
        [string]$PolicyType = 'Compliance',
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows', 'All')]
        [string]$DeviceType = 'All',
        
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = "."
    )
    
    try {
        Write-Host "Generating compliance report..." -ForegroundColor Yellow
        
        # Get devices
        $devices = if ($DeviceType -eq 'All') {
            Get-IntuneDevicesByScope -DeviceType All
        } else {
            Get-IntuneDevicesByScope -DeviceType $DeviceType
        }
        
        $report = @{
            GeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            PolicyId = $PolicyId
            PolicyType = $PolicyType
            DeviceType = $DeviceType
            TotalDevices = $devices.Count
            ComplianceSummary = @{
                Compliant = 0
                NonCompliant = 0
                InGracePeriod = 0
                Unknown = 0
            }
            DeviceDetails = @()
        }
        
        foreach ($device in $devices) {
            $complianceInfo = @{
                DeviceId = $device.id
                DeviceName = $device.deviceName
                OperatingSystem = $device.operatingSystem
                ComplianceState = $device.complianceState
                LastComplianceCheck = $device.complianceGracePeriodExpirationDateTime
            }
            
            # Update summary
            switch ($device.complianceState) {
                'compliant' { $report.ComplianceSummary.Compliant++ }
                'noncompliant' { $report.ComplianceSummary.NonCompliant++ }
                'inGracePeriod' { $report.ComplianceSummary.InGracePeriod++ }
                default { $report.ComplianceSummary.Unknown++ }
            }
            
            $report.DeviceDetails += $complianceInfo
        }
        
        # Generate filename
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $filename = "ComplianceReport_$($DeviceType)_$timestamp.json"
        $fullPath = Join-Path $OutputPath $filename
        
        # Export to JSON
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $fullPath -Encoding UTF8
        
        # Display summary
        Write-Host "`nCompliance Summary:" -ForegroundColor Green
        Write-Host "  Total Devices: $($report.TotalDevices)" -ForegroundColor Cyan
        Write-Host "  Compliant: $($report.ComplianceSummary.Compliant)" -ForegroundColor Green
        Write-Host "  Non-Compliant: $($report.ComplianceSummary.NonCompliant)" -ForegroundColor Red
        Write-Host "  In Grace Period: $($report.ComplianceSummary.InGracePeriod)" -ForegroundColor Yellow
        Write-Host "  Unknown: $($report.ComplianceSummary.Unknown)" -ForegroundColor Gray
        Write-Host "`nReport saved to: $fullPath" -ForegroundColor Cyan
        
        return $fullPath
    }
    catch {
        Write-Error "Failed to generate compliance report: $_"
        throw
    }
}

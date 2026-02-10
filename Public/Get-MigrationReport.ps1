function Get-MigrationReport {
    <#
    .SYNOPSIS
        Generates a comprehensive migration report.
    
    .DESCRIPTION
        Creates a detailed report of device migration status, including:
        - Device counts by type and status
        - Compliance status
        - Policy assignments
        - Migration timeline
    
    .PARAMETER DeviceType
        Filter by device type.
    
    .PARAMETER GroupId
        Filter by group.
    
    .PARAMETER OutputPath
        Path to save the report (defaults to current directory).
    
    .PARAMETER Format
        Report format (JSON, CSV, HTML).
    
    .EXAMPLE
        Get-MigrationReport -DeviceType Windows -Format HTML
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('iOS', 'Android', 'macOS', 'Windows', 'All')]
        [string]$DeviceType = 'All',
        
        [Parameter(Mandatory = $false)]
        [string]$GroupId,
        
        [Parameter(Mandatory = $false)]
        [string]$OutputPath = ".",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('JSON', 'CSV', 'HTML')]
        [string]$Format = 'JSON'
    )
    
    try {
        Write-Host "Generating migration report..." -ForegroundColor Yellow
        
        # Get devices
        $devices = if ($DeviceType -eq 'All') {
            Get-IntuneDevicesByScope -DeviceType All -IncludeCompliance
        } else {
            Get-IntuneDevicesByScope -DeviceType $DeviceType -IncludeCompliance
        }
        
        # Filter by group if specified
        if ($GroupId) {
            $groupMembers = Get-IntuneGraphData -Endpoint "groups/$GroupId/members"
            $memberIds = $groupMembers | ForEach-Object { $_.id }
            $devices = $devices | Where-Object { $_.userId -in $memberIds }
        }
        
        # Build report
        $report = @{
            GeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            DeviceType = $DeviceType
            TotalDevices = $devices.Count
            Statistics = @{
                ByOperatingSystem = @{}
                ByComplianceState = @{}
                ByManagementState = @{}
                ByEnrollmentType = @{}
            }
            Devices = @()
        }
        
        # Calculate statistics
        $devices | Group-Object operatingSystem | ForEach-Object {
            $report.Statistics.ByOperatingSystem[$_.Name] = $_.Count
        }
        
        $devices | Group-Object complianceState | ForEach-Object {
            $report.Statistics.ByComplianceState[$_.Name] = $_.Count
        }
        
        $devices | Group-Object managementState | ForEach-Object {
            $report.Statistics.ByManagementState[$_.Name] = $_.Count
        }
        
        $devices | Group-Object deviceEnrollmentType | ForEach-Object {
            $report.Statistics.ByEnrollmentType[$_.Name] = $_.Count
        }
        
        # Add device details
        foreach ($device in $devices) {
            $deviceInfo = @{
                DeviceId = $device.id
                DeviceName = $device.deviceName
                OperatingSystem = $device.operatingSystem
                OSVersion = $device.osVersion
                ComplianceState = $device.complianceState
                ManagementState = $device.managementState
                EnrollmentType = $device.deviceEnrollmentType
                LastSyncDateTime = $device.lastSyncDateTime
                UserPrincipalName = $device.userPrincipalName
            }
            $report.Devices += $deviceInfo
        }
        
        # Generate filename
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $filename = "MigrationReport_$($DeviceType)_$timestamp.$($Format.ToLower())"
        $fullPath = Join-Path $OutputPath $filename
        
        # Export based on format
        switch ($Format) {
            'JSON' {
                $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $fullPath -Encoding UTF8
            }
            'CSV' {
                $report.Devices | Export-Csv -Path $fullPath -NoTypeInformation -Encoding UTF8
            }
            'HTML' {
                $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Migration Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0078d4; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #0078d4; color: white; }
        .stat { margin: 10px 0; padding: 10px; background-color: #f0f0f0; }
    </style>
</head>
<body>
    <h1>Migration Report</h1>
    <div class="stat"><strong>Generated:</strong> $($report.GeneratedDate)</div>
    <div class="stat"><strong>Total Devices:</strong> $($report.TotalDevices)</div>
    
    <h2>Statistics by Operating System</h2>
    <table>
        <tr><th>Operating System</th><th>Count</th></tr>
        $($report.Statistics.ByOperatingSystem.GetEnumerator() | ForEach-Object { "<tr><td>$($_.Key)</td><td>$($_.Value)</td></tr>" } | Out-String)
    </table>
    
    <h2>Statistics by Compliance State</h2>
    <table>
        <tr><th>Compliance State</th><th>Count</th></tr>
        $($report.Statistics.ByComplianceState.GetEnumerator() | ForEach-Object { "<tr><td>$($_.Key)</td><td>$($_.Value)</td></tr>" } | Out-String)
    </table>
    
    <h2>Device Details</h2>
    <table>
        <tr>
            <th>Device Name</th>
            <th>Operating System</th>
            <th>Compliance</th>
            <th>Management State</th>
            <th>Last Sync</th>
        </tr>
        $($report.Devices | ForEach-Object { 
            "<tr><td>$($_.DeviceName)</td><td>$($_.OperatingSystem) $($_.OSVersion)</td><td>$($_.ComplianceState)</td><td>$($_.ManagementState)</td><td>$($_.LastSyncDateTime)</td></tr>" 
        } | Out-String)
    </table>
</body>
</html>
"@
                $html | Out-File -FilePath $fullPath -Encoding UTF8
            }
        }
        
        Write-Host "`nMigration report generated successfully" -ForegroundColor Green
        Write-Host "  Report file: $fullPath" -ForegroundColor Cyan
        Write-Host "  Format: $Format" -ForegroundColor Cyan
        Write-Host "  Total devices: $($report.TotalDevices)" -ForegroundColor Cyan
        
        return $fullPath
    }
    catch {
        Write-Error "Failed to generate migration report: $_"
        throw
    }
}

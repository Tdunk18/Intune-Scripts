# Security Workspace - Examples

This document contains practical examples for using the Security Workspace spyware detection module.

## Basic Examples

### Example 1: Quick Security Scan
```powershell
# Navigate to the Scripts directory
cd C:\SecurityWorkspace\Scripts

# Run a quick scan with report generation
.\Deploy-SecurityScan.ps1 -ScanType Quick -GenerateReport
```

### Example 2: Full Security Scan
```powershell
# Run a comprehensive full scan
.\Deploy-SecurityScan.ps1 -ScanType Full -GenerateReport
```

### Example 3: Import Module and Use Functions
```powershell
# Import the module
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

# Check for suspicious processes
$processes = Get-SuspiciousProcess
$processes | Format-Table -AutoSize

# Check startup entries
$startups = Get-SuspiciousStartupEntry
$startups | Format-Table -AutoSize

# Check network connections
$connections = Get-SuspiciousNetworkConnection
$connections | Format-Table -AutoSize
```

## Advanced Examples

### Example 4: Custom File Scan
```powershell
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

# Scan specific directories
$customPaths = @(
    "C:\Users\*\Downloads",
    "C:\Users\*\Desktop",
    "D:\Shares\Public"
)

$suspiciousFiles = Get-SuspiciousFile -Paths $customPaths
$suspiciousFiles | Export-Csv -Path "C:\SecurityWorkspace\Reports\CustomFileScan.csv" -NoTypeInformation
```

### Example 5: Scheduled Scan with Email Notification
```powershell
# Create a script that runs the scan and sends email
$scanResults = Start-SpywareScan -QuickScan -GenerateReport

if ($scanResults.TotalThreatsFound -gt 0) {
    $emailParams = @{
        To = "security@company.com"
        From = "noreply@company.com"
        Subject = "ALERT: Spyware Detected on $env:COMPUTERNAME"
        Body = "Threats detected: $($scanResults.TotalThreatsFound). Review the report."
        SmtpServer = "smtp.company.com"
    }
    Send-MailMessage @emailParams
}
```

### Example 6: Automated Remediation with Confirmation
```powershell
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

# Get suspicious processes
$suspiciousProcesses = Get-SuspiciousProcess

# Display findings
Write-Host "Found $($suspiciousProcesses.Count) suspicious processes:"
$suspiciousProcesses | Format-Table ProcessId, ProcessName, ThreatLevel, Reason

# Terminate high-threat processes (with confirmation)
foreach ($process in $suspiciousProcesses | Where-Object { $_.ThreatLevel -eq 'High' }) {
    Write-Host "Terminating: $($process.ProcessName) (PID: $($process.ProcessId))"
    Stop-SuspiciousProcess -ProcessId $process.ProcessId -Confirm
}
```

### Example 7: Export Results to JSON
```powershell
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

# Perform scan
$scanResults = Start-SpywareScan -QuickScan

# Convert to JSON
$jsonReport = @{
    ScanDate = $scanResults.ScanDate
    ComputerName = $scanResults.ComputerName
    TotalThreats = $scanResults.TotalThreatsFound
    Processes = $scanResults.SuspiciousProcesses
    StartupEntries = $scanResults.SuspiciousStartupEntries
    Connections = $scanResults.SuspiciousConnections
} | ConvertTo-Json -Depth 10

# Save to file
$jsonReport | Out-File -FilePath "C:\SecurityWorkspace\Reports\Scan_$(Get-Date -Format 'yyyyMMdd').json"
```

## Integration Examples

### Example 8: Intune Detection Script
```powershell
# Detection script for Intune Win32 app
$logPath = "$env:ProgramData\SecurityWorkspace\Logs"
$latestLog = Get-ChildItem -Path $logPath -Filter "SpywareDetection_*.log" -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending |
             Select-Object -First 1

if ($latestLog -and (Get-Date) - $latestLog.LastWriteTime -lt [TimeSpan]::FromDays(1)) {
    Write-Output "Detected"
    exit 0
} else {
    exit 1
}
```

### Example 9: Compliance Check Script
```powershell
# Check if system is compliant
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

$scanResults = Start-SpywareScan -QuickScan

# Compliance criteria: No high-threat findings
$highThreats = $scanResults.SuspiciousProcesses | Where-Object { $_.ThreatLevel -eq 'High' }

if ($highThreats.Count -eq 0) {
    Write-Output "Compliant"
    exit 0
} else {
    Write-Output "Non-Compliant: $($highThreats.Count) high-threat items found"
    exit 1
}
```

### Example 10: Azure Automation Runbook
```powershell
<#
.SYNOPSIS
    Azure Automation runbook for running spyware scans on VMs
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup
)

# Connect to Azure
Connect-AzAccount -Identity

# Run script on VM
$scriptContent = Get-Content "C:\SecurityWorkspace\Scripts\Deploy-SecurityScan.ps1" -Raw

Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptString $scriptContent

# Retrieve results
# (Add logic to retrieve and process results)
```

## Defensive Examples

### Example 11: Monitor Real-Time Threats
```powershell
# Continuous monitoring script
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

while ($true) {
    Write-Host "Scanning at $(Get-Date)..."
    
    $processes = Get-SuspiciousProcess
    
    if ($processes.Count -gt 0) {
        Write-Host "ALERT: Suspicious processes detected!" -ForegroundColor Red
        $processes | Format-Table
        
        # Send alert (implement your notification method)
        # Send-Alert -Message "Suspicious processes detected"
    }
    
    # Wait 5 minutes before next scan
    Start-Sleep -Seconds 300
}
```

### Example 12: Baseline Comparison
```powershell
# Create baseline
$baseline = Get-SuspiciousProcess
$baseline | Export-Clixml -Path "C:\SecurityWorkspace\Baseline.xml"

# Later, compare against baseline
$current = Get-SuspiciousProcess
$baseline = Import-Clixml -Path "C:\SecurityWorkspace\Baseline.xml"

$newThreats = Compare-Object -ReferenceObject $baseline -DifferenceObject $current -Property ProcessName, Path
if ($newThreats) {
    Write-Host "New threats detected since baseline:"
    $newThreats | Format-Table
}
```

### Example 13: Quarantine Management
```powershell
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

# List quarantined files
$quarantinePath = "C:\SecurityWorkspace\Reports\Quarantine"
$quarantinedFiles = Get-ChildItem -Path $quarantinePath -File

Write-Host "Quarantined Files:"
$quarantinedFiles | Format-Table Name, Length, CreationTime

# Restore a file from quarantine (if false positive)
$fileToRestore = $quarantinedFiles | Where-Object { $_.Name -like "*example.exe*" }
if ($fileToRestore) {
    # Move back to original location (implement carefully)
    # Move-Item -Path $fileToRestore.FullName -Destination "C:\RestoredFiles\"
}
```

## Reporting Examples

### Example 14: Generate Custom Report
```powershell
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

# Perform scan
$scanResults = Start-SpywareScan -QuickScan

# Create custom report
$report = @"
Security Scan Report
====================
Date: $(Get-Date)
Computer: $env:COMPUTERNAME

Summary:
- Suspicious Processes: $($scanResults.SuspiciousProcesses.Count)
- Suspicious Startup: $($scanResults.SuspiciousStartupEntries.Count)
- Suspicious Connections: $($scanResults.SuspiciousConnections.Count)
- Total Threats: $($scanResults.TotalThreatsFound)

High Priority Items:
"@

$highPriority = $scanResults.SuspiciousProcesses | Where-Object { $_.ThreatLevel -eq 'High' }
foreach ($item in $highPriority) {
    $report += "`n- $($item.ProcessName): $($item.Reason)"
}

$report | Out-File -FilePath "C:\SecurityWorkspace\Reports\CustomReport.txt"
```

### Example 15: Dashboard Data Export
```powershell
# Export data for Power BI or other dashboards
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1

$scanResults = Start-SpywareScan -QuickScan

$dashboardData = [PSCustomObject]@{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ComputerName = $env:COMPUTERNAME
    Domain = $env:USERDOMAIN
    TotalThreats = $scanResults.TotalThreatsFound
    HighThreats = ($scanResults.SuspiciousProcesses | Where-Object { $_.ThreatLevel -eq 'High' }).Count
    MediumThreats = ($scanResults.SuspiciousProcesses | Where-Object { $_.ThreatLevel -eq 'Medium' }).Count
    ScanDuration = $scanResults.ScanDuration
}

# Export to CSV for dashboard ingestion
$dashboardData | Export-Csv -Path "C:\SecurityWorkspace\Reports\DashboardData.csv" -Append -NoTypeInformation
```

## Testing Examples

### Example 16: Simulate Threat Detection (Safe Test)
```powershell
# Create a test file with a suspicious name (harmless)
$testPath = "C:\Temp\test-keylogger-test.txt"
New-Item -ItemType File -Path $testPath -Force
"This is a test file for detection" | Out-File -FilePath $testPath

# Run detection
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1
$results = Get-SuspiciousFile -Paths @("C:\Temp")

# Verify detection
if ($results | Where-Object { $_.FileName -like "*keylog*" }) {
    Write-Host "Test PASSED: Suspicious file detected" -ForegroundColor Green
} else {
    Write-Host "Test FAILED: Suspicious file not detected" -ForegroundColor Red
}

# Cleanup
Remove-Item -Path $testPath -Force
```

---

**Note:** Always test these examples in a safe, non-production environment first. Some examples require appropriate permissions and may need modification for your specific environment.

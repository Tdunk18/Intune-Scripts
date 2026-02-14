<#
.SYNOPSIS
    Main script to deploy and run the security workspace spyware detection

.DESCRIPTION
    This script initializes the security workspace, imports the spyware detection module,
    and performs a comprehensive security scan. It's designed to be deployed via Microsoft Intune.

.PARAMETER ScanType
    Type of scan to perform: Quick or Full

.PARAMETER GenerateReport
    Generate an HTML report of the scan results

.PARAMETER AutoRemediate
    Automatically remediate detected threats (requires confirmation)

.EXAMPLE
    .\Deploy-SecurityScan.ps1 -ScanType Quick -GenerateReport
    
.EXAMPLE
    .\Deploy-SecurityScan.ps1 -ScanType Full -GenerateReport -AutoRemediate

.NOTES
    Version: 1.0.0
    Author: Intune Security Team
    Requires: PowerShell 5.1 or higher, Administrator privileges
    Compatible with: Microsoft Intune, Windows 10/11, Windows Server 2016+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Quick', 'Full')]
    [string]$ScanType = 'Quick',
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateReport = $true,
    
    [Parameter(Mandatory = $false)]
    [switch]$AutoRemediate = $false,
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "$PSScriptRoot\..\Config\SecurityConfig.yaml"
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Script initialization
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🛡️  Intune Security Workspace - Spyware Detection 🛡️      ║
║                                                              ║
║   Version: 1.0.0                                            ║
║   GitHub Copilot Ready                                      ║
║   Microsoft Intune Compatible                               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Check prerequisites
Write-Host "`n[✓] Checking prerequisites..." -ForegroundColor Yellow

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[✗] This script requires administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    exit 1
}

Write-Host "[✓] Running with administrator privileges" -ForegroundColor Green

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-Host "[✓] PowerShell version: $($psVersion.Major).$($psVersion.Minor)" -ForegroundColor Green

if ($psVersion.Major -lt 5) {
    Write-Host "[✗] PowerShell 5.1 or higher is required!" -ForegroundColor Red
    exit 1
}

# Import the SpywareDetection module
Write-Host "`n[✓] Importing SpywareDetection module..." -ForegroundColor Yellow
$modulePath = Join-Path $PSScriptRoot "..\Modules\SpywareDetection.psm1"

if (-not (Test-Path $modulePath)) {
    Write-Host "[✗] SpywareDetection module not found at: $modulePath" -ForegroundColor Red
    exit 1
}

try {
    Import-Module $modulePath -Force -ErrorAction Stop
    Write-Host "[✓] SpywareDetection module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "[✗] Failed to import module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Check Windows Defender status
Write-Host "`n[✓] Checking Windows Defender status..." -ForegroundColor Yellow
try {
    $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
    
    if ($defenderStatus) {
        Write-Host "[✓] Windows Defender is available" -ForegroundColor Green
        Write-Host "    - Real-time Protection: $($defenderStatus.RealTimeProtectionEnabled)" -ForegroundColor White
        Write-Host "    - Antivirus Enabled: $($defenderStatus.AntivirusEnabled)" -ForegroundColor White
        Write-Host "    - Antispyware Enabled: $($defenderStatus.AntispywareEnabled)" -ForegroundColor White
        
        if (-not $defenderStatus.RealTimeProtectionEnabled) {
            Write-Host "[!] Warning: Real-time protection is disabled" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "[!] Warning: Unable to get Windows Defender status" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[!] Warning: Windows Defender check failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Display scan configuration
Write-Host "`n[✓] Scan Configuration:" -ForegroundColor Yellow
Write-Host "    - Scan Type: $ScanType" -ForegroundColor White
Write-Host "    - Generate Report: $GenerateReport" -ForegroundColor White
Write-Host "    - Auto Remediate: $AutoRemediate" -ForegroundColor White
Write-Host "    - Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "    - User: $env:USERNAME" -ForegroundColor White

# Perform the security scan
Write-Host "`n[✓] Starting $ScanType security scan..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

try {
    $scanParams = @{
        QuickScan = ($ScanType -eq 'Quick')
        GenerateReport = $GenerateReport
    }
    
    $scanResults = Start-SpywareScan @scanParams
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    # Display detailed results
    if ($scanResults.SuspiciousProcesses.Count -gt 0) {
        Write-Host "`n[!] Suspicious Processes Detected:" -ForegroundColor Red
        $scanResults.SuspiciousProcesses | ForEach-Object {
            Write-Host "    - $($_.ProcessName) (PID: $($_.ProcessId)) - $($_.Reason)" -ForegroundColor Yellow
        }
    }
    
    if ($scanResults.SuspiciousStartupEntries.Count -gt 0) {
        Write-Host "`n[!] Suspicious Startup Entries Detected:" -ForegroundColor Red
        $scanResults.SuspiciousStartupEntries | ForEach-Object {
            Write-Host "    - $($_.EntryName): $($_.EntryValue)" -ForegroundColor Yellow
        }
    }
    
    if ($scanResults.SuspiciousConnections.Count -gt 0) {
        Write-Host "`n[!] Suspicious Network Connections Detected:" -ForegroundColor Red
        $scanResults.SuspiciousConnections | ForEach-Object {
            Write-Host "    - $($_.ProcessName) -> $($_.RemoteAddress):$($_.RemotePort)" -ForegroundColor Yellow
        }
    }
    
    if ($scanResults.SuspiciousFiles.Count -gt 0) {
        Write-Host "`n[!] Suspicious Files Detected:" -ForegroundColor Red
        $scanResults.SuspiciousFiles | Select-Object -First 10 | ForEach-Object {
            Write-Host "    - $($_.FileName) - $($_.Reason)" -ForegroundColor Yellow
        }
        
        if ($scanResults.SuspiciousFiles.Count -gt 10) {
            Write-Host "    ... and $($scanResults.SuspiciousFiles.Count - 10) more files (see report for details)" -ForegroundColor Yellow
        }
    }
    
    # Auto-remediation
    if ($AutoRemediate -and $scanResults.TotalThreatsFound -gt 0) {
        Write-Host "`n[!] Auto-remediation is enabled. Preparing to remediate threats..." -ForegroundColor Yellow
        Write-Host "[!] Note: This is a dry-run. Manual review is recommended." -ForegroundColor Yellow
        
        # In a production environment, you would implement actual remediation here
        # For safety, this script requires manual intervention
        Write-Host "[i] Please review the report and manually remediate threats." -ForegroundColor Cyan
    }
    
    # Exit code based on scan results
    if ($scanResults.TotalThreatsFound -gt 0) {
        Write-Host "`n[!] Security scan completed with threats detected!" -ForegroundColor Red
        Write-Host "[i] Review the report and take appropriate action." -ForegroundColor Yellow
        exit 1  # Non-zero exit code for Intune compliance
    }
    else {
        Write-Host "`n[✓] Security scan completed successfully!" -ForegroundColor Green
        Write-Host "[✓] No threats detected." -ForegroundColor Green
        exit 0  # Zero exit code for Intune compliance
    }
}
catch {
    Write-Host "`n[✗] Scan failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 2  # Error exit code
}
finally {
    Write-Host "`n[✓] Scan complete. Thank you for using Intune Security Workspace!" -ForegroundColor Cyan
}

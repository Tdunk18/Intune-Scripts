<#
.SYNOPSIS
    Advanced Spyware Detection Module for Microsoft Intune
    
.DESCRIPTION
    This module provides comprehensive spyware detection capabilities using the latest
    security features and best practices. It integrates with Microsoft Defender,
    Windows Security, and provides real-time threat detection.
    
.NOTES
    Version: 1.0.0
    Author: Intune Security Team
    GitHub Copilot Ready: Yes
    Last Updated: 2026-02-14
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

# Module Variables
$script:LogPath = "$PSScriptRoot\..\Logs"
$script:ReportPath = "$PSScriptRoot\..\Reports"
$script:ConfigPath = "$PSScriptRoot\..\Config"

# Initialize logging
if (-not (Test-Path $script:LogPath)) {
    New-Item -ItemType Directory -Path $script:LogPath -Force | Out-Null
}

if (-not (Test-Path $script:ReportPath)) {
    New-Item -ItemType Directory -Path $script:ReportPath -Force | Out-Null
}

#region Logging Functions

<#
.SYNOPSIS
    Writes structured log entries with timestamp and severity level
#>
function Write-SecurityLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Critical')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory = $false)]
        [string]$Component = 'SpywareDetection'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [$Component] $Message"
    
    $logFile = Join-Path $script:LogPath "SpywareDetection_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logEntry
    
    switch ($Level) {
        'Warning' { Write-Warning $Message }
        'Error' { Write-Error $Message }
        'Critical' { Write-Error "CRITICAL: $Message" }
        default { Write-Verbose $Message }
    }
}

#endregion

#region Threat Detection Functions

<#
.SYNOPSIS
    Scans running processes for known spyware signatures
#>
function Get-SuspiciousProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$IncludeSystemProcesses
    )
    
    Write-SecurityLog -Message "Starting suspicious process scan" -Level Info
    
    # Known spyware process patterns (regex)
    $spywarePatterns = @(
        'keylog',
        'spy(ware)?',
        'trojan',
        'backdoor',
        'rat\d*',
        'rootkit',
        'malware',
        'adware',
        'pcrat',
        'darkcomet',
        'njrat',
        'remcos',
        'nanocore'
    )
    
    $suspiciousProcesses = @()
    $processes = Get-Process | Select-Object Id, ProcessName, Path, Company, Description, StartTime
    
    foreach ($process in $processes) {
        # Check process name against patterns
        foreach ($pattern in $spywarePatterns) {
            if ($process.ProcessName -match $pattern) {
                Write-SecurityLog -Message "Suspicious process detected: $($process.ProcessName) (PID: $($process.Id))" -Level Warning
                
                $suspiciousProcesses += [PSCustomObject]@{
                    ProcessId = $process.Id
                    ProcessName = $process.ProcessName
                    Path = $process.Path
                    Company = $process.Company
                    Description = $process.Description
                    StartTime = $process.StartTime
                    ThreatLevel = 'High'
                    Reason = "Name matches spyware pattern: $pattern"
                }
            }
        }
        
        # Check for processes without company information (unsigned)
        if ([string]::IsNullOrEmpty($process.Company) -and -not [string]::IsNullOrEmpty($process.Path)) {
            if ($process.Path -notmatch 'Windows\\System32' -and $process.Path -notmatch 'Program Files') {
                Write-SecurityLog -Message "Unsigned process detected: $($process.ProcessName)" -Level Info
                
                $suspiciousProcesses += [PSCustomObject]@{
                    ProcessId = $process.Id
                    ProcessName = $process.ProcessName
                    Path = $process.Path
                    Company = 'N/A'
                    Description = $process.Description
                    StartTime = $process.StartTime
                    ThreatLevel = 'Medium'
                    Reason = 'Unsigned executable outside system directories'
                }
            }
        }
    }
    
    Write-SecurityLog -Message "Suspicious process scan completed. Found $($suspiciousProcesses.Count) suspicious processes" -Level Info
    return $suspiciousProcesses
}

<#
.SYNOPSIS
    Scans registry for suspicious startup entries
#>
function Get-SuspiciousStartupEntry {
    [CmdletBinding()]
    param()
    
    Write-SecurityLog -Message "Starting registry startup scan" -Level Info
    
    $startupLocations = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
    )
    
    $suspiciousEntries = @()
    
    foreach ($location in $startupLocations) {
        if (Test-Path $location) {
            $entries = Get-ItemProperty -Path $location -ErrorAction SilentlyContinue
            
            if ($entries) {
                $entries.PSObject.Properties | Where-Object { $_.Name -notmatch 'PS(Path|ParentPath|ChildName|Provider)' } | ForEach-Object {
                    $entryName = $_.Name
                    $entryValue = $_.Value
                    
                    # Check for suspicious paths
                    if ($entryValue -match '(temp|appdata\\local\\temp|programdata\\[^\\]+\.exe|users\\public)' -or
                        $entryValue -match '\.(vbs|js|bat|cmd|ps1)$' -or
                        $entryValue -notmatch '(program files|windows)') {
                        
                        Write-SecurityLog -Message "Suspicious startup entry: $entryName = $entryValue" -Level Warning
                        
                        $suspiciousEntries += [PSCustomObject]@{
                            RegistryPath = $location
                            EntryName = $entryName
                            EntryValue = $entryValue
                            ThreatLevel = 'High'
                            Reason = 'Suspicious location or file type'
                        }
                    }
                }
            }
        }
    }
    
    Write-SecurityLog -Message "Registry startup scan completed. Found $($suspiciousEntries.Count) suspicious entries" -Level Info
    return $suspiciousEntries
}

<#
.SYNOPSIS
    Checks for suspicious network connections
#>
function Get-SuspiciousNetworkConnection {
    [CmdletBinding()]
    param()
    
    Write-SecurityLog -Message "Starting network connection scan" -Level Info
    
    $suspiciousConnections = @()
    
    # Check if Get-NetTCPConnection is available (Windows only)
    if (-not (Get-Command -Name Get-NetTCPConnection -ErrorAction SilentlyContinue)) {
        Write-SecurityLog -Message "Get-NetTCPConnection not available on this platform. Skipping network scan." -Level Warning
        return $suspiciousConnections
    }
    
    $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue
    
    # Known command and control (C2) ports
    $suspiciousPorts = @(4444, 5555, 6666, 7777, 8888, 9999, 1337, 31337)
    
    foreach ($connection in $connections) {
        $isSuspicious = $false
        $reason = ""
        
        # Check for suspicious ports
        if ($connection.RemotePort -in $suspiciousPorts) {
            $isSuspicious = $true
            $reason = "Known C2 port: $($connection.RemotePort)"
        }
        
        # Check for non-standard ports with system processes
        if ($connection.LocalPort -gt 49152 -and $connection.RemotePort -gt 49152) {
            $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
            if ($process -and [string]::IsNullOrEmpty($process.Company)) {
                $isSuspicious = $true
                $reason = "High-range port communication from unsigned process"
            }
        }
        
        if ($isSuspicious) {
            $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
            
            Write-SecurityLog -Message "Suspicious connection: $($connection.LocalAddress):$($connection.LocalPort) -> $($connection.RemoteAddress):$($connection.RemotePort)" -Level Warning
            
            $suspiciousConnections += [PSCustomObject]@{
                LocalAddress = $connection.LocalAddress
                LocalPort = $connection.LocalPort
                RemoteAddress = $connection.RemoteAddress
                RemotePort = $connection.RemotePort
                State = $connection.State
                ProcessId = $connection.OwningProcess
                ProcessName = if ($process) { $process.ProcessName } else { "Unknown" }
                ThreatLevel = 'High'
                Reason = $reason
            }
        }
    }
    
    Write-SecurityLog -Message "Network connection scan completed. Found $($suspiciousConnections.Count) suspicious connections" -Level Info
    return $suspiciousConnections
}

<#
.SYNOPSIS
    Scans common spyware installation directories
#>
function Get-SuspiciousFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Paths = @(
            "$env:TEMP",
            "$env:APPDATA",
            "$env:LOCALAPPDATA",
            "$env:ProgramData"
        )
    )
    
    Write-SecurityLog -Message "Starting suspicious file scan" -Level Info
    
    $suspiciousFiles = @()
    $suspiciousExtensions = @('.exe', '.dll', '.vbs', '.js', '.bat', '.cmd', '.ps1', '.scr')
    
    foreach ($path in $Paths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | 
                Where-Object { $_.Extension -in $suspiciousExtensions -and $_.CreationTime -gt (Get-Date).AddDays(-7) }
            
            foreach ($file in $files) {
                # Check if file is signed
                $signature = Get-AuthenticodeSignature -FilePath $file.FullName -ErrorAction SilentlyContinue
                
                if ($signature.Status -ne 'Valid') {
                    Write-SecurityLog -Message "Suspicious file detected: $($file.FullName)" -Level Info
                    
                    $suspiciousFiles += [PSCustomObject]@{
                        FullPath = $file.FullName
                        FileName = $file.Name
                        Extension = $file.Extension
                        Size = $file.Length
                        CreationTime = $file.CreationTime
                        LastModified = $file.LastWriteTime
                        IsSigned = ($signature.Status -eq 'Valid')
                        ThreatLevel = 'Medium'
                        Reason = 'Recent unsigned executable in user directory'
                    }
                }
            }
        }
    }
    
    Write-SecurityLog -Message "Suspicious file scan completed. Found $($suspiciousFiles.Count) suspicious files" -Level Info
    return $suspiciousFiles
}

<#
.SYNOPSIS
    Checks Windows Defender threat history
#>
function Get-DefenderThreatHistory {
    [CmdletBinding()]
    param()
    
    Write-SecurityLog -Message "Retrieving Windows Defender threat history" -Level Info
    
    try {
        $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue | Select-Object -First 50
        
        if ($threats) {
            Write-SecurityLog -Message "Retrieved $($threats.Count) threat detections from Windows Defender" -Level Info
            return $threats
        } else {
            Write-SecurityLog -Message "No recent threats detected by Windows Defender" -Level Info
            return @()
        }
    }
    catch {
        Write-SecurityLog -Message "Failed to retrieve Defender threat history: $($_.Exception.Message)" -Level Warning
        return @()
    }
}

#endregion

#region Comprehensive Scanning

<#
.SYNOPSIS
    Performs a comprehensive security scan for spyware
#>
function Start-SpywareScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$QuickScan,
        
        [Parameter(Mandatory = $false)]
        [switch]$GenerateReport
    )
    
    Write-SecurityLog -Message "=== Starting Comprehensive Spyware Scan ===" -Level Info
    $scanStartTime = Get-Date
    
    $scanResults = @{
        ScanDate = $scanStartTime
        ScanType = if ($QuickScan) { "Quick" } else { "Full" }
        ComputerName = $env:COMPUTERNAME
        Username = $env:USERNAME
        SuspiciousProcesses = @()
        SuspiciousStartupEntries = @()
        SuspiciousConnections = @()
        SuspiciousFiles = @()
        DefenderThreats = @()
        TotalThreatsFound = 0
        ScanDuration = $null
    }
    
    # Scan processes
    Write-Host "Scanning processes..." -ForegroundColor Cyan
    $scanResults.SuspiciousProcesses = Get-SuspiciousProcess
    
    # Scan startup entries
    Write-Host "Scanning startup entries..." -ForegroundColor Cyan
    $scanResults.SuspiciousStartupEntries = Get-SuspiciousStartupEntry
    
    # Scan network connections
    Write-Host "Scanning network connections..." -ForegroundColor Cyan
    $scanResults.SuspiciousConnections = Get-SuspiciousNetworkConnection
    
    # Scan files (only in full scan)
    if (-not $QuickScan) {
        Write-Host "Scanning files..." -ForegroundColor Cyan
        $scanResults.SuspiciousFiles = Get-SuspiciousFile
    }
    
    # Get Defender history
    Write-Host "Checking Windows Defender history..." -ForegroundColor Cyan
    $scanResults.DefenderThreats = Get-DefenderThreatHistory
    
    # Calculate totals
    $scanResults.TotalThreatsFound = 
        $scanResults.SuspiciousProcesses.Count + 
        $scanResults.SuspiciousStartupEntries.Count + 
        $scanResults.SuspiciousConnections.Count + 
        $scanResults.SuspiciousFiles.Count
    
    $scanEndTime = Get-Date
    $scanResults.ScanDuration = ($scanEndTime - $scanStartTime).TotalSeconds
    
    Write-SecurityLog -Message "=== Spyware Scan Completed ===" -Level Info
    Write-SecurityLog -Message "Total threats found: $($scanResults.TotalThreatsFound)" -Level Info
    Write-SecurityLog -Message "Scan duration: $($scanResults.ScanDuration) seconds" -Level Info
    
    # Display summary
    Write-Host "`n=== Scan Summary ===" -ForegroundColor Green
    Write-Host "Scan completed in $([math]::Round($scanResults.ScanDuration, 2)) seconds" -ForegroundColor White
    Write-Host "Suspicious Processes: $($scanResults.SuspiciousProcesses.Count)" -ForegroundColor Yellow
    Write-Host "Suspicious Startup Entries: $($scanResults.SuspiciousStartupEntries.Count)" -ForegroundColor Yellow
    Write-Host "Suspicious Network Connections: $($scanResults.SuspiciousConnections.Count)" -ForegroundColor Yellow
    Write-Host "Suspicious Files: $($scanResults.SuspiciousFiles.Count)" -ForegroundColor Yellow
    Write-Host "Total Threats: $($scanResults.TotalThreatsFound)" -ForegroundColor $(if ($scanResults.TotalThreatsFound -gt 0) { "Red" } else { "Green" })
    
    # Generate report if requested
    if ($GenerateReport) {
        Export-SecurityReport -ScanResults $scanResults
    }
    
    return $scanResults
}

#endregion

#region Reporting

<#
.SYNOPSIS
    Exports scan results to a detailed report
#>
function Export-SecurityReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$ScanResults
    )
    
    $reportFile = Join-Path $script:ReportPath "SpywareReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Spyware Detection Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #d32f2f; }
        h2 { color: #1976d2; border-bottom: 2px solid #1976d2; padding-bottom: 5px; }
        .summary { background-color: #fff; padding: 15px; border-radius: 5px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .threat-high { color: #d32f2f; font-weight: bold; }
        .threat-medium { color: #f57c00; font-weight: bold; }
        .threat-low { color: #fbc02d; }
        table { width: 100%; border-collapse: collapse; background-color: #fff; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background-color: #1976d2; color: white; padding: 10px; text-align: left; }
        td { padding: 8px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f5f5f5; }
        .footer { margin-top: 30px; padding-top: 15px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <h1>🛡️ Spyware Detection Report</h1>
    
    <div class="summary">
        <h2>Scan Summary</h2>
        <p><strong>Computer Name:</strong> $($ScanResults.ComputerName)</p>
        <p><strong>Scan Date:</strong> $($ScanResults.ScanDate)</p>
        <p><strong>Scan Type:</strong> $($ScanResults.ScanType)</p>
        <p><strong>Scan Duration:</strong> $([math]::Round($ScanResults.ScanDuration, 2)) seconds</p>
        <p><strong>Total Threats Found:</strong> <span class="threat-high">$($ScanResults.TotalThreatsFound)</span></p>
    </div>
    
    <h2>Suspicious Processes ($($ScanResults.SuspiciousProcesses.Count))</h2>
"@
    
    if ($ScanResults.SuspiciousProcesses.Count -gt 0) {
        $htmlReport += "<table><tr><th>PID</th><th>Process Name</th><th>Path</th><th>Threat Level</th><th>Reason</th></tr>"
        foreach ($process in $ScanResults.SuspiciousProcesses) {
            $htmlReport += "<tr><td>$($process.ProcessId)</td><td>$($process.ProcessName)</td><td>$($process.Path)</td><td class='threat-$($process.ThreatLevel.ToLower())'>$($process.ThreatLevel)</td><td>$($process.Reason)</td></tr>"
        }
        $htmlReport += "</table>"
    } else {
        $htmlReport += "<p>No suspicious processes detected.</p>"
    }
    
    $htmlReport += "<h2>Suspicious Startup Entries ($($ScanResults.SuspiciousStartupEntries.Count))</h2>"
    
    if ($ScanResults.SuspiciousStartupEntries.Count -gt 0) {
        $htmlReport += "<table><tr><th>Registry Path</th><th>Entry Name</th><th>Entry Value</th><th>Threat Level</th><th>Reason</th></tr>"
        foreach ($entry in $ScanResults.SuspiciousStartupEntries) {
            $htmlReport += "<tr><td>$($entry.RegistryPath)</td><td>$($entry.EntryName)</td><td>$($entry.EntryValue)</td><td class='threat-$($entry.ThreatLevel.ToLower())'>$($entry.ThreatLevel)</td><td>$($entry.Reason)</td></tr>"
        }
        $htmlReport += "</table>"
    } else {
        $htmlReport += "<p>No suspicious startup entries detected.</p>"
    }
    
    $htmlReport += "<h2>Suspicious Network Connections ($($ScanResults.SuspiciousConnections.Count))</h2>"
    
    if ($ScanResults.SuspiciousConnections.Count -gt 0) {
        $htmlReport += "<table><tr><th>Local Address</th><th>Local Port</th><th>Remote Address</th><th>Remote Port</th><th>Process</th><th>Threat Level</th><th>Reason</th></tr>"
        foreach ($connection in $ScanResults.SuspiciousConnections) {
            $htmlReport += "<tr><td>$($connection.LocalAddress)</td><td>$($connection.LocalPort)</td><td>$($connection.RemoteAddress)</td><td>$($connection.RemotePort)</td><td>$($connection.ProcessName) (PID: $($connection.ProcessId))</td><td class='threat-$($connection.ThreatLevel.ToLower())'>$($connection.ThreatLevel)</td><td>$($connection.Reason)</td></tr>"
        }
        $htmlReport += "</table>"
    } else {
        $htmlReport += "<p>No suspicious network connections detected.</p>"
    }
    
    $htmlReport += "<h2>Suspicious Files ($($ScanResults.SuspiciousFiles.Count))</h2>"
    
    if ($ScanResults.SuspiciousFiles.Count -gt 0) {
        $htmlReport += "<table><tr><th>File Name</th><th>Full Path</th><th>Size (bytes)</th><th>Created</th><th>Threat Level</th><th>Reason</th></tr>"
        foreach ($file in $ScanResults.SuspiciousFiles) {
            $htmlReport += "<tr><td>$($file.FileName)</td><td>$($file.FullPath)</td><td>$($file.Size)</td><td>$($file.CreationTime)</td><td class='threat-$($file.ThreatLevel.ToLower())'>$($file.ThreatLevel)</td><td>$($file.Reason)</td></tr>"
        }
        $htmlReport += "</table>"
    } else {
        $htmlReport += "<p>No suspicious files detected.</p>"
    }
    
    $htmlReport += @"
    <div class="footer">
        <p>Generated by Intune Security Workspace - Spyware Detection Module v1.0.0</p>
        <p>This report should be reviewed by security personnel. False positives may occur.</p>
    </div>
</body>
</html>
"@
    
    $htmlReport | Out-File -FilePath $reportFile -Encoding UTF8
    Write-SecurityLog -Message "Report exported to: $reportFile" -Level Info
    Write-Host "Report saved to: $reportFile" -ForegroundColor Green
    
    return $reportFile
}

#endregion

#region Remediation Functions

<#
.SYNOPSIS
    Terminates a suspicious process
#>
function Stop-SuspiciousProcess {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessId,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    if ($PSCmdlet.ShouldProcess("Process ID $ProcessId", "Terminate process")) {
        try {
            Stop-Process -Id $ProcessId -Force:$Force -ErrorAction Stop
            Write-SecurityLog -Message "Successfully terminated process ID: $ProcessId" -Level Info
            Write-Host "Process $ProcessId terminated successfully." -ForegroundColor Green
            return $true
        }
        catch {
            Write-SecurityLog -Message "Failed to terminate process ID $ProcessId : $($_.Exception.Message)" -Level Error
            Write-Host "Failed to terminate process: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

<#
.SYNOPSIS
    Removes a suspicious startup entry
#>
function Remove-SuspiciousStartupEntry {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,
        
        [Parameter(Mandatory = $true)]
        [string]$EntryName
    )
    
    if ($PSCmdlet.ShouldProcess("$RegistryPath\$EntryName", "Remove registry entry")) {
        try {
            Remove-ItemProperty -Path $RegistryPath -Name $EntryName -ErrorAction Stop
            Write-SecurityLog -Message "Successfully removed startup entry: $RegistryPath\$EntryName" -Level Info
            Write-Host "Startup entry removed successfully." -ForegroundColor Green
            return $true
        }
        catch {
            Write-SecurityLog -Message "Failed to remove startup entry $RegistryPath\$EntryName : $($_.Exception.Message)" -Level Error
            Write-Host "Failed to remove startup entry: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

<#
.SYNOPSIS
    Quarantines a suspicious file
#>
function Move-SuspiciousFileToQuarantine {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    $quarantinePath = Join-Path $script:ReportPath "Quarantine"
    
    if (-not (Test-Path $quarantinePath)) {
        New-Item -ItemType Directory -Path $quarantinePath -Force | Out-Null
    }
    
    if ($PSCmdlet.ShouldProcess($FilePath, "Move to quarantine")) {
        try {
            $fileName = [System.IO.Path]::GetFileName($FilePath)
            $destinationPath = Join-Path $quarantinePath "$fileName.quarantine_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            
            Move-Item -Path $FilePath -Destination $destinationPath -ErrorAction Stop
            Write-SecurityLog -Message "Successfully quarantined file: $FilePath to $destinationPath" -Level Info
            Write-Host "File quarantined successfully to: $destinationPath" -ForegroundColor Green
            return $true
        }
        catch {
            Write-SecurityLog -Message "Failed to quarantine file $FilePath : $($_.Exception.Message)" -Level Error
            Write-Host "Failed to quarantine file: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

#endregion

# Export module members
Export-ModuleMember -Function @(
    'Start-SpywareScan',
    'Get-SuspiciousProcess',
    'Get-SuspiciousStartupEntry',
    'Get-SuspiciousNetworkConnection',
    'Get-SuspiciousFile',
    'Get-DefenderThreatHistory',
    'Export-SecurityReport',
    'Stop-SuspiciousProcess',
    'Remove-SuspiciousStartupEntry',
    'Move-SuspiciousFileToQuarantine',
    'Write-SecurityLog'
)

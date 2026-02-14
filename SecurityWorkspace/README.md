# 🛡️ Security Workspace - Spyware Detection

Welcome to the **Intune Security Workspace**! This comprehensive security solution provides advanced spyware detection capabilities designed for Microsoft Intune environments.

## 🎯 Features

### Core Capabilities
- **✅ Process Monitoring** - Detect suspicious processes with known spyware signatures
- **✅ Startup Entry Scanning** - Monitor registry startup locations for malicious entries
- **✅ Network Connection Analysis** - Identify suspicious network activity and C2 communications
- **✅ File System Scanning** - Detect unsigned executables in sensitive locations
- **✅ Windows Defender Integration** - Leverage built-in threat detection
- **✅ Comprehensive Reporting** - Generate detailed HTML reports with findings
- **✅ Automated Remediation** - Optional threat removal capabilities (with confirmation)
- **✅ GitHub Copilot Ready** - Well-documented, AI-friendly code structure

### Security Features
- 🔒 Administrator privilege enforcement
- 🔒 Comprehensive logging with rotation
- 🔒 Safe quarantine mechanism for suspicious files
- 🔒 Multiple threat levels (High, Medium, Low)
- 🔒 Configurable detection sensitivity
- 🔒 Integration with Microsoft Defender

### Intune Integration
- 📱 Exit codes for compliance checking
- 📱 Scheduled scanning support
- 📱 Remote deployment ready
- 📱 Configurable security profiles
- 📱 Centralized configuration management

## 📁 Directory Structure

```
SecurityWorkspace/
├── Modules/
│   └── SpywareDetection.psm1    # Main detection module
├── Scripts/
│   └── Deploy-SecurityScan.ps1  # Deployment script
├── Config/
│   └── SecurityConfig.yaml      # Configuration file
├── Logs/                        # Scan logs (auto-created)
├── Reports/                     # HTML reports (auto-created)
│   └── Quarantine/             # Quarantined files (auto-created)
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or higher
- Administrator privileges
- Windows Defender (recommended)

### Basic Usage

1. **Quick Scan** (Recommended for regular checks)
   ```powershell
   cd SecurityWorkspace/Scripts
   .\Deploy-SecurityScan.ps1 -ScanType Quick -GenerateReport
   ```

2. **Full Scan** (Comprehensive analysis)
   ```powershell
   .\Deploy-SecurityScan.ps1 -ScanType Full -GenerateReport
   ```

3. **With Auto-Remediation** (Use with caution)
   ```powershell
   .\Deploy-SecurityScan.ps1 -ScanType Quick -GenerateReport -AutoRemediate
   ```

## 📖 Module Functions

### Detection Functions

#### `Start-SpywareScan`
Performs a comprehensive security scan for spyware.

```powershell
# Quick scan with report
Start-SpywareScan -QuickScan -GenerateReport

# Full scan
Start-SpywareScan -GenerateReport
```

#### `Get-SuspiciousProcess`
Scans running processes for known spyware signatures.

```powershell
$suspiciousProcesses = Get-SuspiciousProcess
$suspiciousProcesses | Format-Table
```

#### `Get-SuspiciousStartupEntry`
Scans registry startup locations for malicious entries.

```powershell
$startupThreats = Get-SuspiciousStartupEntry
$startupThreats | Format-Table
```

#### `Get-SuspiciousNetworkConnection`
Checks for suspicious network connections.

```powershell
$connections = Get-SuspiciousNetworkConnection
$connections | Format-Table
```

#### `Get-SuspiciousFile`
Scans for suspicious files in common spyware locations.

```powershell
$files = Get-SuspiciousFile
$files | Format-Table
```

#### `Get-DefenderThreatHistory`
Retrieves Windows Defender threat detection history.

```powershell
$threats = Get-DefenderThreatHistory
$threats | Format-Table
```

### Remediation Functions

#### `Stop-SuspiciousProcess`
Terminates a suspicious process.

```powershell
Stop-SuspiciousProcess -ProcessId 1234 -Confirm
```

#### `Remove-SuspiciousStartupEntry`
Removes a suspicious startup entry from registry.

```powershell
Remove-SuspiciousStartupEntry -RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -EntryName "SuspiciousApp"
```

#### `Move-SuspiciousFileToQuarantine`
Quarantines a suspicious file.

```powershell
Move-SuspiciousFileToQuarantine -FilePath "C:\Temp\suspicious.exe" -Confirm
```

### Reporting Functions

#### `Export-SecurityReport`
Exports scan results to an HTML report.

```powershell
Export-SecurityReport -ScanResults $scanResults
```

## 🔧 Configuration

Edit `Config/SecurityConfig.yaml` to customize:
- Detection sensitivity
- Spyware patterns
- Monitored directories
- Auto-remediation settings
- Reporting preferences
- Logging configuration

Example configuration:
```yaml
SpywareDetection:
  DetectionSensitivity: Medium
  EnableProcessMonitoring: true
  EnableNetworkMonitoring: true
  AutoRemediation:
    Enabled: false
    RequireConfirmation: true
```

## 📊 Reports

Scan reports are automatically generated in HTML format and saved to the `Reports/` directory. Each report includes:

- Executive summary with threat counts
- Detailed process analysis
- Startup entry findings
- Network connection details
- File system scan results
- Threat level indicators
- Timestamps and metadata

Reports can be viewed in any web browser and are suitable for:
- Security audits
- Compliance documentation
- Incident response
- Management reporting

## 🔍 Detection Capabilities

### Process Detection
- Known spyware process names (keyloggers, RATs, trojans)
- Unsigned processes in suspicious locations
- Processes with missing company information
- Memory injection indicators

### Startup Entry Detection
- Registry Run/RunOnce locations
- Suspicious file paths (temp directories)
- Script-based startup entries (VBS, JS, PS1)
- Unsigned executables

### Network Detection
- Known C2 (Command & Control) ports
- High-range port communications
- Unsigned process network activity
- Suspicious connection patterns

### File Detection
- Recent unsigned executables
- Files in temporary directories
- Known malware file patterns
- Suspicious file extensions

## 🔐 Security Best Practices

1. **Run Regular Scans**
   - Schedule weekly quick scans
   - Perform monthly full scans
   - Scan after software installations

2. **Review Reports**
   - Always review scan reports
   - Investigate high-severity findings
   - Document false positives

3. **Use Confirmation**
   - Always use `-Confirm` for remediation actions
   - Backup before removing files
   - Test in non-production first

4. **Keep Updated**
   - Update spyware signatures regularly
   - Review and update configuration
   - Check for module updates

5. **Integration**
   - Deploy via Intune for centralized management
   - Monitor exit codes for compliance
   - Collect reports centrally

## 🚨 Exit Codes

The deployment script returns standard exit codes for Intune compliance:

- `0` - Success, no threats detected
- `1` - Threats detected, review required
- `2` - Scan error or failure

## 📋 Logging

All activities are logged to the `Logs/` directory with:
- Timestamped entries
- Severity levels (Info, Warning, Error, Critical)
- Component identification
- Automatic log rotation

Log files are named: `SpywareDetection_YYYYMMDD.log`

## 🤝 Integration Examples

### Microsoft Intune Deployment

1. Package the SecurityWorkspace folder
2. Create a Win32 app in Intune
3. Set installation command:
   ```
   powershell.exe -ExecutionPolicy Bypass -File "SecurityWorkspace\Scripts\Deploy-SecurityScan.ps1" -ScanType Quick -GenerateReport
   ```
4. Set detection rule: Check for log file existence
5. Configure compliance policy based on exit codes

### Scheduled Task

```powershell
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\SecurityWorkspace\Scripts\Deploy-SecurityScan.ps1" -ScanType Quick -GenerateReport'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Security-SpywareScan" -Description "Weekly spyware detection scan" -RunLevel Highest
```

## 🐛 Troubleshooting

### Common Issues

**"Script requires administrator privileges"**
- Solution: Run PowerShell as Administrator

**"Cannot import module"**
- Solution: Verify file paths and permissions
- Check execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**"Windows Defender not available"**
- Solution: Some functions will work without Defender
- Install and enable Windows Defender for full functionality

**False Positives**
- Solution: Review the SecurityConfig.yaml and adjust detection sensitivity
- Add known-safe applications to exclusion lists

## 📝 Version History

### Version 1.0.0 (2026-02-14)
- Initial release
- Core spyware detection capabilities
- Windows Defender integration
- HTML report generation
- Basic remediation functions
- Intune compatibility
- GitHub Copilot ready code structure

## 🤖 GitHub Copilot Integration

This module is optimized for GitHub Copilot with:
- Comprehensive inline documentation
- Clear function naming conventions
- Detailed parameter descriptions
- Usage examples in comments
- Type hints and validation
- Structured code organization

## 📄 License

This project is part of the Intune-Scripts repository. Please refer to the LICENSE file in the root directory.

## 👥 Contributing

Contributions are welcome! Please ensure:
- Code follows PowerShell best practices
- Functions include proper documentation
- Changes are tested in multiple environments
- Security implications are considered

## ⚠️ Disclaimer

This tool is provided as-is for security monitoring and detection purposes. Always:
- Test in a non-production environment first
- Review findings before taking action
- Maintain backups before remediation
- Follow your organization's security policies
- Be aware that false positives can occur

## 📧 Support

For issues, questions, or contributions, please visit the GitHub repository or contact the security team.

---

**Made with ❤️ for Microsoft Intune Administrators**

*Keeping your environment secure, one scan at a time!* 🛡️

# Intune Deployment Package for Security Workspace

## Overview
This deployment package contains the Security Workspace spyware detection solution for Microsoft Intune.

## Package Contents
- SpywareDetection Module (PowerShell)
- Deployment Scripts
- Configuration Files
- Documentation

## Deployment Methods

### Method 1: Win32 App Deployment

1. **Create Win32 App Package**
   ```powershell
   # Use the Microsoft Win32 Content Prep Tool
   .\IntuneWinAppUtil.exe -c "C:\SecurityWorkspace" -s "Deploy-SecurityScan.ps1" -o "C:\Output"
   ```

2. **Configure in Intune**
   - Navigate to: Apps > All apps > Add
   - App type: Windows app (Win32)
   - Upload the .intunewin file
   
3. **Installation Settings**
   - Install command: 
     ```
     powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "Deploy-SecurityScan.ps1" -ScanType Quick -GenerateReport
     ```
   - Uninstall command: 
     ```
     cmd.exe /c rd /s /q "%ProgramFiles%\SecurityWorkspace"
     ```

4. **Requirements**
   - Operating system: Windows 10 1607 or later
   - Architecture: x64
   - Minimum OS: Windows 10 1607

5. **Detection Rules**
   - Type: File
   - Path: `%ProgramFiles%\SecurityWorkspace\Modules`
   - File or folder: `SpywareDetection.psm1`
   - Detection method: File or folder exists

### Method 2: PowerShell Script Deployment

1. **In Intune Portal**
   - Navigate to: Devices > Scripts > Add > Windows 10 and later
   - Upload: `Deploy-SecurityScan.ps1`
   
2. **Script Settings**
   - Run this script using the logged-on credentials: No
   - Enforce script signature check: No
   - Run script in 64-bit PowerShell: Yes

3. **Assignments**
   - Assign to appropriate device groups

### Method 3: Configuration Profile (Remediation)

1. **Create Remediation Script**
   - Detection script: Check if scan is needed
   - Remediation script: `Deploy-SecurityScan.ps1`

2. **Schedule**
   - Run once per day
   - Run every hour (for real-time monitoring)

## Compliance Policy

Create a custom compliance policy to check scan results:

```xml
<CustomSettings>
  <Name>SpywareDetection</Name>
  <Script>
    $logPath = "$env:ProgramData\SecurityWorkspace\Logs"
    $latestLog = Get-ChildItem $logPath -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestLog -and (Get-Date) - $latestLog.LastWriteTime -lt [TimeSpan]::FromDays(7)) {
      return $true
    }
    return $false
  </Script>
</CustomSettings>
```

## Exit Codes

| Code | Meaning | Action Required |
|------|---------|----------------|
| 0 | Success, no threats | None |
| 1 | Threats detected | Review and remediate |
| 2 | Scan error | Check logs |

## Configuration Management

### Centralized Configuration
Deploy `SecurityConfig.yaml` via:
1. Group Policy Preferences
2. Intune Configuration Profile
3. Azure File Share

### Security Profiles

**High Security**
```yaml
DetectionSensitivity: High
AutoRemediation: true
ScanFrequency: Daily
```

**Medium Security**
```yaml
DetectionSensitivity: Medium
AutoRemediation: false
ScanFrequency: Weekly
```

**Low Security**
```yaml
DetectionSensitivity: Low
AutoRemediation: false
ScanFrequency: Monthly
```

## Monitoring & Reporting

### Log Analytics Integration
Send logs to Azure Log Analytics:

```powershell
# Custom log ingestion
$WorkspaceId = "YOUR_WORKSPACE_ID"
$SharedKey = "YOUR_SHARED_KEY"

# Send scan results to Log Analytics
# (Implementation depends on your Log Analytics setup)
```

### Report Collection
Collect HTML reports via:
1. Azure Storage Account
2. SharePoint Online
3. Network Share

## Troubleshooting

### Common Issues

**Issue: Script execution disabled**
Solution: Configure execution policy via Intune
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**Issue: Permission denied**
Solution: Ensure scripts run with SYSTEM privileges in Intune

**Issue: Windows Defender unavailable**
Solution: Ensure Defender is enabled and up-to-date

## Best Practices

1. **Pilot Deployment**
   - Test on a pilot group first
   - Validate results before broad deployment
   - Monitor for false positives

2. **Scheduling**
   - Run quick scans weekly
   - Run full scans monthly
   - Avoid peak business hours

3. **Reporting**
   - Centralize report collection
   - Review high-severity findings weekly
   - Document false positives

4. **Maintenance**
   - Update signatures monthly
   - Review configuration quarterly
   - Archive old logs and reports

## Security Considerations

1. **Least Privilege**
   - Scripts require admin privileges
   - Consider using managed identities

2. **Data Protection**
   - Reports may contain sensitive data
   - Secure report storage location
   - Implement retention policies

3. **Audit Trail**
   - All actions are logged
   - Maintain logs for compliance
   - Regular log review

## Support

For issues or questions:
1. Check logs in `Logs/` directory
2. Review documentation
3. Contact security team
4. Submit GitHub issue

## Updates

Check for updates regularly:
- Module updates
- Signature updates
- Configuration updates
- Documentation updates

---

**Document Version:** 1.0.0  
**Last Updated:** 2026-02-14  
**Maintained by:** Intune Security Team

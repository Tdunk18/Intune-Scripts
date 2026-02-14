# 🚀 Quick Start Guide - Security Workspace

Get started with the Security Workspace spyware detection module in just a few minutes!

## 📋 Prerequisites

Before you begin, ensure you have:
- ✅ Windows 10/11 or Windows Server 2016+
- ✅ PowerShell 5.1 or higher
- ✅ Administrator privileges
- ✅ Windows Defender enabled (recommended)

## 🎯 Step-by-Step Setup

### Step 1: Clone or Download the Repository

If you haven't already, get the SecurityWorkspace folder on your system:

```powershell
# Option A: Clone the repository
git clone https://github.com/Tdunk18/Intune-Scripts.git
cd Intune-Scripts/SecurityWorkspace

# Option B: Download and extract to C:\SecurityWorkspace
```

### Step 2: Open PowerShell as Administrator

1. Press `Win + X`
2. Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

### Step 3: Set Execution Policy (if needed)

```powershell
# Allow running scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 4: Run Your First Scan

```powershell
# Navigate to the Scripts directory
cd C:\SecurityWorkspace\Scripts

# Run a quick scan
.\Deploy-SecurityScan.ps1 -ScanType Quick -GenerateReport
```

That's it! Your first security scan is now running. 🎉

## 📊 Understanding the Results

### Console Output
The scan will display:
- ✅ System checks (admin rights, PowerShell version, Defender status)
- 🔍 Scanning progress (processes, startup, network, files)
- 📈 Summary with threat counts
- 🚨 Alerts for any suspicious findings

### HTML Report
After the scan completes, you'll find a detailed HTML report in:
```
SecurityWorkspace/Reports/SpywareReport_YYYYMMDD_HHMMSS.html
```

Open it in any web browser to view:
- Executive summary
- Detailed findings by category
- Threat levels (High, Medium, Low)
- Recommendations

### Log Files
Activity logs are saved to:
```
SecurityWorkspace/Logs/SpywareDetection_YYYYMMDD.log
```

## 🔧 Common Commands

### Quick Scan (Fast, Essential Checks)
```powershell
.\Deploy-SecurityScan.ps1 -ScanType Quick -GenerateReport
```

### Full Scan (Comprehensive Analysis)
```powershell
.\Deploy-SecurityScan.ps1 -ScanType Full -GenerateReport
```

### Using the Module Directly
```powershell
# Import the module
Import-Module ..\Modules\SpywareDetection.psm1

# Check suspicious processes
Get-SuspiciousProcess | Format-Table

# Check startup entries
Get-SuspiciousStartupEntry | Format-Table

# Check network connections
Get-SuspiciousNetworkConnection | Format-Table
```

## 🛠️ Customization

### Adjust Detection Sensitivity

Edit `SecurityWorkspace/Config/SecurityConfig.yaml`:

```yaml
SpywareDetection:
  DetectionSensitivity: Medium  # Change to: Low, Medium, or High
```

### Add Custom Spyware Patterns

Add patterns to watch for:

```yaml
SpywareDetection:
  SpywareProcessPatterns:
    - keylog
    - yourpattern
    - customspyware
```

### Change Monitored Directories

```yaml
SpywareDetection:
  MonitoredDirectories:
    - "%TEMP%"
    - "%APPDATA%"
    - "C:\YourCustomPath"
```

## 🔄 Scheduling Regular Scans

### Option 1: Windows Task Scheduler

```powershell
# Create a scheduled task for weekly scans
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
    -Argument '-ExecutionPolicy Bypass -File "C:\SecurityWorkspace\Scripts\Deploy-SecurityScan.ps1" -ScanType Quick -GenerateReport'

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am

Register-ScheduledTask -Action $action -Trigger $trigger `
    -TaskName "Security-WeeklyScan" `
    -Description "Weekly spyware detection scan" `
    -RunLevel Highest
```

### Option 2: Deploy via Microsoft Intune

See `DEPLOYMENT.md` for detailed Intune deployment instructions.

## 🚨 What to Do if Threats Are Found

1. **Review the Report**
   - Open the HTML report
   - Review each finding carefully
   - Note the threat level (High, Medium, Low)

2. **Investigate High-Priority Items First**
   - Research unknown processes
   - Verify if they're legitimate software
   - Check file signatures and locations

3. **Take Action**
   ```powershell
   # Import the module
   Import-Module ..\Modules\SpywareDetection.psm1
   
   # Terminate a suspicious process (with confirmation)
   Stop-SuspiciousProcess -ProcessId 1234 -Confirm
   
   # Quarantine a suspicious file
   Move-SuspiciousFileToQuarantine -FilePath "C:\Path\To\File.exe" -Confirm
   
   # Remove a startup entry
   Remove-SuspiciousStartupEntry -RegistryPath "HKCU:\...\Run" -EntryName "BadEntry" -Confirm
   ```

4. **Run a Follow-up Scan**
   ```powershell
   .\Deploy-SecurityScan.ps1 -ScanType Full -GenerateReport
   ```

## ⚠️ False Positives

Some legitimate software may trigger alerts. Common false positives:
- Development tools
- Remote access software (TeamViewer, AnyDesk)
- System monitoring utilities
- Backup software

**What to do:**
1. Verify the software is legitimate
2. Add to exclusions in `SecurityConfig.yaml` if needed
3. Document known false positives

## 🆘 Troubleshooting

### "Cannot import module"
**Solution:**
```powershell
# Check file paths
Get-ChildItem C:\SecurityWorkspace\Modules\*.psm1

# Import with full path
Import-Module C:\SecurityWorkspace\Modules\SpywareDetection.psm1 -Force
```

### "Access Denied" or "Permission Denied"
**Solution:**
```powershell
# Ensure you're running as Administrator
# Right-click PowerShell → Run as Administrator
```

### "Execution Policy" Error
**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### No Threats Found but System Seems Infected
**Solution:**
1. Update Windows Defender definitions
2. Run Windows Defender full scan
3. Run the SecurityWorkspace full scan
4. Consider professional malware removal tools

## 📚 Next Steps

Now that you're up and running:

1. ✅ **Read the full documentation**: `README.md`
2. ✅ **Explore examples**: `EXAMPLES.md`
3. ✅ **Learn about Intune deployment**: `DEPLOYMENT.md`
4. ✅ **Customize settings**: `Config/SecurityConfig.yaml`
5. ✅ **Schedule regular scans**: Set up automation
6. ✅ **Monitor reports**: Review regularly

## 🤝 Need Help?

- 📖 Check the full documentation
- 💬 Review examples and use cases
- 🐛 Submit issues on GitHub
- 📧 Contact your security team

## 🎓 Learning Resources

**PowerShell Basics:**
- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [PowerShell Gallery](https://www.powershellgallery.com/)

**Microsoft Intune:**
- [Intune Documentation](https://docs.microsoft.com/mem/intune/)
- [Intune App Deployment](https://docs.microsoft.com/mem/intune/apps/)

**Security:**
- [Windows Defender](https://docs.microsoft.com/windows/security/threat-protection/)
- [Microsoft Security](https://www.microsoft.com/security)

---

## 🎉 You're All Set!

You now have a powerful spyware detection tool running on your system. Remember to:
- Run scans regularly
- Review reports promptly
- Keep the tool updated
- Share with your team

**Happy securing! 🛡️**

---

*Made with ❤️ for Microsoft Intune Administrators*

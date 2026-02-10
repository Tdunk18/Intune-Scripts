# Script Requirements

This document outlines the requirements and standards that all scripts in this repository must follow to ensure consistency, security, and maintainability during Intune migrations and management tasks.

## 1. Authentication and Permissions

### Microsoft Entra ID Authentication
- Scripts should implement secure authentication via Microsoft Entra ID using modules like `Microsoft.Graph.Intune`.
- Use modern authentication methods compatible with organizational security policies.

### Delegated Permissions
- Verify that proper user delegated permissions are in place for the Intune service in Microsoft Entra ID.
- Clearly document the minimum required permissions for each script in the script header or accompanying documentation.

### MFA Compliance
- Ensure compatibility with multi-factor authentication (MFA).
- Scripts must not bypass or circumvent MFA requirements.

### Token Caching
- Optionally provide token caching for session persistence to improve usability.
- Ensure tokens are stored securely and never logged or exposed in plain text.

## 2. Script Design Principles

### Idempotency
- Ensure that scripts are idempotent, meaning that they can be safely re-run without creating duplicate configurations or introducing errors.
- Implement checks to verify if a configuration already exists before creating it.

### Modularity
- Break tasks into smaller modules for better reusability and maintainability.
- Separate concerns such as device enrollment, app management, or policy configuration tasks into distinct functions or modules.

### Error Handling
- Use robust error-handling mechanisms, such as try/catch/finally blocks.
- Provide meaningful error messages that help users understand what went wrong and how to resolve issues.
- Implement graceful degradation where appropriate.

### Logging and Auditing

#### Log File Naming
- Ensure log filenames always use the name of the script being executed.
- Logs should either append to existing log files or create new log files that overwrite the old ones to prevent log creation creep.

#### Log Storage
- Ensure log files always store two copies of information:
  1. A portable log that is always logged to a `Logs` folder next to the script execution location.
  2. A log tied to where the Intune service collects logs (typically the standard Intune log location).

#### Timestamping
- Record execution logs with timestamps to help trace issues during migration.
- Use consistent timestamp formats across all scripts (e.g., ISO 8601 format).

#### Security and Privacy
- Avoid logging sensitive information, such as:
  - Access tokens
  - SAS Keys
  - Passwords or secrets
  - PII (Personally Identifiable Information) related materials

### Output Standardization
- Standardize script outputs in easy-to-parse formats like CSV or JSON.
- Provide clear, structured output that can be consumed by other tools or scripts.
- Include summary information at the end of script execution (e.g., number of items processed, success/failure counts).

## Best Practices

- **Documentation**: Include comprehensive inline comments and script headers explaining purpose, parameters, and usage.
- **Version Control**: Maintain version information in script headers.
- **Testing**: Test scripts in a non-production environment before deploying to production.
- **Validation**: Validate input parameters and environment prerequisites before executing main logic.
- **Progress Reporting**: For long-running operations, provide progress updates to the user.

## Example Script Template

```powershell
<#
.SYNOPSIS
    Brief description of what the script does.

.DESCRIPTION
    Detailed description of the script's functionality.

.PARAMETER ParameterName
    Description of each parameter.

.NOTES
    Version: 1.0.0
    Author: Your Name
    Date: YYYY-MM-DD
    
    Required Permissions:
    - DeviceManagementConfiguration.ReadWrite.All
    - DeviceManagementManagedDevices.Read.All

.EXAMPLE
    .\ScriptName.ps1 -Parameter "Value"
    Description of what this example does.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Parameter
)

# Initialize logging
$ScriptName = $MyInvocation.MyCommand.Name
$LogFolder = Join-Path -Path $PSScriptRoot -ChildPath "Logs"
$IntuneLogFolder = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = Join-Path -Path $LogFolder -ChildPath "$($ScriptName -replace '\.ps1$','')_$Timestamp.log"
$IntuneLogFile = Join-Path -Path $IntuneLogFolder -ChildPath "$($ScriptName -replace '\.ps1$','')_$Timestamp.log"

# Create log directories if they don't exist
if (-not (Test-Path $LogFolder)) { New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null }
if (-not (Test-Path $IntuneLogFolder)) { New-Item -ItemType Directory -Path $IntuneLogFolder -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Add-Content -Path $IntuneLogFile -Value $LogMessage
    Write-Host $LogMessage
}

try {
    Write-Log "Script started: $ScriptName"
    
    # Authenticate to Microsoft Graph
    Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All" -ErrorAction Stop
    Write-Log "Successfully authenticated to Microsoft Graph"
    
    # Main script logic here
    
    Write-Log "Script completed successfully"
}
catch {
    Write-Log "Error occurred: $_" -Level "ERROR"
    throw
}
finally {
    # Cleanup
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}
```

## Compliance Checklist

Before submitting a script to this repository, ensure it meets the following criteria:

- [ ] Implements Microsoft Entra ID authentication
- [ ] Documents required permissions
- [ ] Supports MFA
- [ ] Is idempotent
- [ ] Includes proper error handling
- [ ] Creates logs in both portable and Intune service locations
- [ ] Uses script name in log filenames
- [ ] Does not log sensitive information
- [ ] Outputs data in standardized format (CSV/JSON)
- [ ] Includes comprehensive documentation
- [ ] Has been tested in a non-production environment

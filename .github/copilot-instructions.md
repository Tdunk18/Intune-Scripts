# GitHub Copilot Instructions for Intune Scripts

This document provides comprehensive guidelines for developing PowerShell scripts for Microsoft Intune management and migrations within this repository.

## 1. Authentication and Permissions

### Azure AD Authentication
- Scripts **must** implement Azure AD authentication for secure access to Microsoft Graph and Intune APIs
- Use modules like `Microsoft.Graph.Intune` or the newer `Microsoft.Graph` PowerShell module
- Example authentication pattern:
  ```powershell
  Connect-MgGraph -Scopes "DeviceManagementManagedDevices.ReadWrite.All"
  ```

### Delegated Permissions
- Verify that proper user delegated permissions are in place for the Intune service
- Document required permissions at the top of each script in comments
- Common required permissions include:
  - `DeviceManagementManagedDevices.ReadWrite.All`
  - `DeviceManagementConfiguration.ReadWrite.All`
  - `DeviceManagementApps.ReadWrite.All`
  - `Group.Read.All` or `Group.ReadWrite.All`

### MFA Compliance
- Ensure all scripts are compatible with multi-factor authentication (MFA)
- Use interactive authentication when MFA is required
- Avoid service principals for user-delegated scenarios where MFA is enforced

### Token Caching
- Optionally provide token caching for session persistence to improve user experience
- Use built-in token caching mechanisms from the Microsoft.Graph module
- Never store tokens in plaintext files

## 2. Script Design Principles

### Idempotency
- Each script **must** be idempotent to avoid duplicating objects or creating configuration conflicts in Intune
- Check for existing resources before creating new ones
- Use `-ErrorAction SilentlyContinue` judiciously and handle expected errors
- Example:
  ```powershell
  $existingPolicy = Get-MgDeviceManagementDeviceConfiguration | Where-Object DisplayName -eq $policyName
  if (-not $existingPolicy) {
      # Create new policy
  }
  ```

### Modularity
- Separate tasks into different script modules for better adaptability and reuse
- Common modules to consider:
  - App management
  - Device configuration
  - Reporting and analytics
  - User and group management
- Use PowerShell functions and modules to organize code

### Error Handling
- Include robust error trapping with `try/catch/finally` blocks
- Provide meaningful error messages that help users understand what went wrong
- Example:
  ```powershell
  try {
      # Script logic
  }
  catch {
      Write-Log "ERROR: Failed to process device: $($_.Exception.Message)" -Level Error
      throw
  }
  finally {
      # Cleanup code
  }
  ```

### Logging and Auditing

#### Two Sets of Logs
- **Portable logs**: Follow the execution of the script for local troubleshooting
  - Default location: Same directory as the script or a `Logs` subdirectory
- **Intune-collected logs**: Separate location collected by Intune's diagnostic system
  - Location: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\` (Windows)
  - Or appropriate platform-specific locations for macOS/Linux

#### Logging Requirements
- Write detailed logs with timestamps to help trace script execution and facilitate debugging
- **Critical**: Ensure sensitive information (e.g., tokens, PII, credentials) is **never** logged
- Default to verbose logging for all scripts
- Use the script's file name as the log file name (e.g., `MigrateDevices.ps1` → `MigrateDevices.log`)
- Always overwrite old log files or append to them with rotation to prevent log file creep
  - Implement log rotation if appending (e.g., max 10MB file size)

#### Logging Function Template
```powershell
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Portable log
    Add-Content -Path $script:PortableLogPath -Value $logMessage
    
    # Intune-collected log
    Add-Content -Path $script:IntuneLogPath -Value $logMessage
    
    # Also write to console
    switch ($Level) {
        'Warning' { Write-Warning $Message }
        'Error'   { Write-Error $Message }
        default   { Write-Verbose $Message -Verbose }
    }
}
```

### Output Standardization
- Provide uniform outputs such as CSV or JSON that users can parse for further use
- Example: Export device migration results to CSV with columns: DeviceName, Status, Timestamp, Error
- Use `Export-Csv`, `ConvertTo-Json`, or similar cmdlets

## 3. Device and Policy Management

### Device Scope
- Allow users to select device types for policy application:
  - iOS/iPadOS
  - Android
  - macOS
  - Windows 10/11
- Use parameters or prompts to filter by platform
- Example:
  ```powershell
  param(
      [ValidateSet('Windows', 'iOS', 'Android', 'macOS', 'All')]
      [string]$Platform = 'All'
  )
  ```

### Policy Assignment
- Scripts should handle policy assignments to specific groups
- Support assignment types:
  - Compliance policies
  - Configuration profiles
  - App protection policies
  - App configuration policies
- Example:
  ```powershell
  $assignment = New-MgDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $policyId -Target @{
      "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
      "groupId" = $groupId
  }
  ```

### Pilot-Friendly Implementation
- Include options to test scripts on pilot groups before large-scale deployment
- Provide `-WhatIf` parameter support where applicable
- Allow specifying pilot group IDs or names
- Example:
  ```powershell
  param(
      [switch]$PilotMode,
      [string]$PilotGroupName = "Intune-Pilot-Group"
  )
  ```

### Rollback Plans
- Offer clear rollback procedures if issues arise during changes or migrations
- Document rollback steps in script comments
- Optionally provide companion rollback scripts
- Export configurations before making changes for potential restoration

## 4. Validation and Reporting

### Pre-migration Checks
- Validate device readiness before migration:
  - Check if devices are co-managed or hybrid AD-joined
  - Verify device enrollment status
  - Check OS version compatibility
- Check user licensing:
  - Ensure users have Intune licenses
  - Verify license SKUs include required features

### Migration Reporting
- Provide pre- and post-migration reports including:
  - Number of devices migrated
  - Compliance status before and after
  - Errors encountered with device details
  - Migration timeline and duration
- Give users analytics on migrated devices:
  - Current compliance states
  - Policy application status
  - Last check-in times

### Dependency Validation
- Check for and report dependencies:
  - App prerequisites
  - Required configurations
  - Group memberships
  - Conditional access policies
- Warn users about missing dependencies before proceeding

## 5. Graph API Integration

### Microsoft Graph Support
- Use Microsoft Graph API for interacting with Intune
- Leverage the `Microsoft.Graph` PowerShell module (v2.0+)
- Use SDK cmdlets when available (e.g., `Get-MgDeviceManagementManagedDevice`)
- For custom operations, use `Invoke-MgGraphRequest`

### OData Querying
- Implement OData querying for fetching filtered data efficiently
- Use query parameters:
  - `$filter`: Filter results (e.g., `$filter=operatingSystem eq 'Windows'`)
  - `$select`: Choose specific properties to return
  - `$expand`: Include related entities
  - `$top`: Limit number of results
  - `$skip`: Pagination support
- Example:
  ```powershell
  Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Windows'" -Select "deviceName,id,complianceState" -Top 100
  ```

### Rate Limiting and Retries
- Handle Graph API throttling by including retry logic with exponential backoff
- Implement retry logic for transient errors (429, 503, 504)
- Example retry function:
  ```powershell
  function Invoke-GraphRequestWithRetry {
      param($Uri, $Method = 'GET', $Body = $null, $MaxRetries = 5)
      
      $retryCount = 0
      $completed = $false
      
      while (-not $completed) {
          try {
              $result = Invoke-MgGraphRequest -Uri $Uri -Method $Method -Body $Body
              $completed = $true
              return $result
          }
          catch {
              if ($_.Exception.Response.StatusCode -eq 429 -and $retryCount -lt $MaxRetries) {
                  $retryAfter = if ($_.Exception.Response.Headers.RetryAfter) { 
                      $_.Exception.Response.Headers.RetryAfter.Delta.TotalSeconds 
                  } else { 
                      [math]::Pow(2, $retryCount) 
                  }
                  Write-Log "Rate limited. Retrying after $retryAfter seconds..." -Level Warning
                  Start-Sleep -Seconds $retryAfter
                  $retryCount++
              }
              else {
                  throw
              }
          }
      }
  }
  ```

## 6. Ease of Use and Customization

### User Inputs
- Supply parameterized scripts with well-documented default values
- Use `[Parameter()]` attributes with help text
- Provide clear prompts or validated input for:
  - Group selection
  - Device targets
  - Policy names
- Example:
  ```powershell
  param(
      [Parameter(Mandatory=$true, HelpMessage="Enter the name of the target group")]
      [string]$GroupName,
      
      [Parameter(Mandatory=$false, HelpMessage="Specify device platform")]
      [ValidateSet('Windows', 'iOS', 'Android', 'macOS')]
      [string]$Platform = 'Windows'
  )
  ```

### Intune Tenancy Detection
- Automatically detect the organization's Intune tenant setup
- Retrieve tenant information using Graph API
- Example:
  ```powershell
  $organization = Get-MgOrganization
  Write-Log "Connected to tenant: $($organization.DisplayName) ($($organization.Id))"
  ```

### Documentation
- Accompany scripts with detailed inline comments
- Include examples in comment-based help
- Use PowerShell comment-based help syntax:
  ```powershell
  <#
  .SYNOPSIS
      Brief description of the script
  
  .DESCRIPTION
      Detailed description of what the script does
  
  .PARAMETER GroupName
      Description of the GroupName parameter
  
  .EXAMPLE
      .\ScriptName.ps1 -GroupName "IT-Devices"
      Description of what this example does
  
  .NOTES
      Author: Your Name
      Version: 1.0
      Required Permissions: DeviceManagementManagedDevices.ReadWrite.All
  #>
  ```

### Cross-Platform Execution
- Ensure scripts can run on Windows, macOS, and Linux where applicable
- Use PowerShell 7+ features for cross-platform compatibility
- Avoid Windows-specific cmdlets unless necessary
- Use `$PSVersionTable.Platform` to detect the platform and adjust paths accordingly
- Example:
  ```powershell
  if ($PSVersionTable.Platform -eq 'Win32NT') {
      $logPath = "$env:ProgramData\IntuneScripts\Logs"
  } else {
      $logPath = "/var/log/intune-scripts"
  }
  ```

## 7. Security Best Practices

### Encryption
- Encrypt sensitive values during storage and use:
  - App configuration secrets
  - Certificates and private keys
  - API keys or tokens
- Use PowerShell's `ConvertTo-SecureString` and `ConvertFrom-SecureString`
- For Windows, leverage DPAPI for encryption
- For cross-platform scenarios, use certificate-based encryption

### Execution Policies
- Warn users about required PowerShell execution policy
- Document in script header that RemoteSigned or Bypass may be required
- Example warning in script:
  ```powershell
  # EXECUTION POLICY REQUIREMENT:
  # This script requires PowerShell execution policy set to RemoteSigned or Bypass
  # Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### Approval Controls
- Include interim approval prompts for critical or destructive actions **only if script is designed with interactive controls**
- For automated/scheduled scripts, omit interactive prompts
- Use `$PSCmdlet.ShouldProcess()` for `-WhatIf` and `-Confirm` support
- Example:
  ```powershell
  param(
      [switch]$Force
  )
  
  if (-not $Force) {
      $confirmation = Read-Host "This will delete all devices in the group. Continue? (Y/N)"
      if ($confirmation -ne 'Y') {
          Write-Log "Operation cancelled by user" -Level Warning
          exit
      }
  }
  ```

### Credential Handling
- Use secure credential prompts (e.g., `Get-Credential`)
- **Never** store passwords or secrets in plaintext in scripts
- Use Azure Key Vault for storing and retrieving secrets when possible
- For interactive scripts: `$cred = Get-Credential`
- For automated scripts: Use managed identities or certificate-based authentication

## 8. Compliance and Governance

### Audit Compliance
- Scripts should respect organizational compliance policies:
  - Device naming conventions
  - Security baselines
  - Conditional access practices
- Verify compliance policies before and after script execution
- Example:
  ```powershell
  # Verify device naming convention
  if ($deviceName -notmatch '^[A-Z]{3}-[0-9]{6}$') {
      Write-Log "Device name '$deviceName' does not match naming convention" -Level Warning
  }
  ```

### Audit Logs
- Log crucial script actions to Azure Monitor or Storage accounts when possible
- For enterprise scenarios, consider integrating with:
  - Azure Log Analytics
  - Azure Storage
  - Event Hub
- Include action details: who, what, when, where
- Example log entry: "User admin@contoso.com migrated device ABC-123456 from hybrid to Intune at 2024-01-15 10:30:00 UTC"

### Retention and Disposal
- Implement cleanup code for temporary data or files
- Remove temporary files created during script execution
- Clear sensitive data from memory
- Example:
  ```powershell
  finally {
      # Clean up temporary files
      if (Test-Path $tempFile) {
          Remove-Item $tempFile -Force
      }
      
      # Clear sensitive variables
      if ($securePassword) {
          $securePassword.Dispose()
      }
  }
  ```

## 9. Templates and Libraries

### Configuration-as-Code
- Provide libraries or templates for common actions:
  - Importing device lists from CSV
  - Configuring compliance profiles
  - Deploying Defender policies
  - Creating app protection policies
- Use JSON or PowerShell objects for configuration templates
- Example configuration template:
  ```powershell
  $compliancePolicyTemplate = @{
      displayName = "Windows 10 Compliance Policy"
      description = "Standard compliance policy for Windows 10 devices"
      passwordRequired = $true
      passwordMinimumLength = 8
      osMinimumVersion = "10.0.19041.0"
  }
  ```

### Community-Friendly Design
- Make scripts discoverable and equivalent to a PowerShell module for shared use
- Structure as a proper PowerShell module with:
  - Module manifest (.psd1)
  - Exported functions
  - Help documentation
- Provide facilities for contributors to extend functionality
- Follow PowerShell best practices:
  - Use approved verbs (Get, Set, New, Remove, etc.)
  - Implement pipeline support
  - Use standard parameter names

## 10. Scalability

### Batch Processing
- Enable parallel processing for large workloads using:
  - `ForEach-Object -Parallel` (PowerShell 7+)
  - PowerShell jobs
  - Runspaces
- Example:
  ```powershell
  $devices | ForEach-Object -Parallel {
      # Process each device in parallel
      $device = $_
      # ... processing logic
  } -ThrottleLimit 10
  ```

### Rate Control
- Allow users to control script execution rates to prevent overloading the service
- Provide parameters for:
  - Batch size (number of items to process at once)
  - Delay between batches
  - Maximum concurrent operations
- Example:
  ```powershell
  param(
      [int]$BatchSize = 50,
      [int]$DelayBetweenBatches = 5,
      [int]$MaxConcurrentJobs = 10
  )
  ```

### Bulk Actions
- Support migrating multiple users, groups, or devices in a single run
- Process items in batches to manage API limits
- Provide progress indicators for long-running operations
- Example:
  ```powershell
  $totalDevices = $devices.Count
  $processed = 0
  
  foreach ($batch in ($devices | Group-Object -Property {[math]::Floor($script:currentIndex++ / $BatchSize)})) {
      # Process batch
      foreach ($device in $batch.Group) {
          # Process device
          $processed++
          Write-Progress -Activity "Processing Devices" -Status "$processed of $totalDevices" -PercentComplete (($processed / $totalDevices) * 100)
      }
      
      # Delay between batches to respect rate limits
      if ($processed -lt $totalDevices) {
          Start-Sleep -Seconds $DelayBetweenBatches
      }
  }
  ```

---

## Quick Reference Checklist

When creating or reviewing Intune scripts, ensure they meet these key criteria:

- [ ] Implements Azure AD authentication with proper permissions documented
- [ ] Is idempotent and won't create duplicates
- [ ] Includes comprehensive error handling (try/catch/finally)
- [ ] Creates two sets of logs (portable + Intune-collected) with verbose logging by default
- [ ] Never logs sensitive information (tokens, PII, credentials)
- [ ] Supports parameterized inputs with validation
- [ ] Includes inline documentation and comment-based help
- [ ] Uses Microsoft Graph API with OData querying
- [ ] Implements retry logic with exponential backoff for rate limiting
- [ ] Handles credentials securely (no plaintext passwords)
- [ ] Provides clear output (CSV/JSON) for reporting
- [ ] Supports pilot/test modes where appropriate
- [ ] Is cross-platform compatible (Windows/macOS/Linux) when possible
- [ ] Respects organizational compliance policies
- [ ] Cleans up temporary files and sensitive data
- [ ] Supports batch processing and rate control for scalability
- [ ] Includes rollback documentation or procedures

---

**Note**: These instructions should be followed for all PowerShell scripts developed in this repository. They ensure consistency, security, and maintainability across all Intune management and migration scripts.

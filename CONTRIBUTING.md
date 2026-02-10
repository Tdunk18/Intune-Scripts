# Contributing to Intune-Scripts

Thank you for considering contributing to this repository! This guide will help you add your scripts in the right location.

## How to Contribute

### 1. Choose the Right Folder

Select the appropriate folder based on your script's purpose:

- **Cloud/**: Cloud-based management scripts (Intune, Entra ID, etc.)
- **On-Premises/**: On-premises infrastructure scripts (AD, GPO, SCCM)
- **Migration/**: Scripts specifically for migration phases
- **Reporting/**: Scripts for generating reports and analytics across Intune and Azure
- **Maintenance/**: Ongoing maintenance and optimization scripts
- **GraphAPI/**: Scripts that primarily use Microsoft Graph API (see "Working with Microsoft Graph API" section below)

### 2. Script Requirements

All scripts should:
- Include a header comment block with:
  - Script description
  - Author information
  - Prerequisites
  - Parameters explanation
  - Usage examples
- Follow PowerShell best practices
- Include error handling
- Support `-WhatIf` for destructive operations
- Include verbose output for troubleshooting

### 3. Script Template

```powershell
<#
.SYNOPSIS
    Brief description of what the script does

.DESCRIPTION
    Detailed description of the script's functionality

.PARAMETER ParameterName
    Description of the parameter

.EXAMPLE
    .\Script-Name.ps1 -ParameterName "Value"
    Description of what this example does

.NOTES
    Author: Your Name
    Date: YYYY-MM-DD
    Version: 1.0
    Prerequisites:
    - Required modules
    - Required permissions
    - Other requirements

.LINK
    Related documentation or resources
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$ParameterName
)

# Script logic here
```

### 4. Testing

Before submitting:
- Test your script in a non-production environment
- Verify error handling works correctly
- Ensure `-WhatIf` support functions properly
- Test with different parameter combinations

### 5. Reporting Scripts

If you're contributing a reporting script, place it in the **Reporting/** folder under the appropriate subfolder:

#### Reporting Subfolders:
- **Compliance-Reports/**: Device and policy compliance tracking
- **Device-Reports/**: Device inventory, health status, lifecycle reporting
- **Security-Reports/**: Security posture, threats, BitLocker status
- (Create new subfolders as needed for specialized report types)

#### Reporting Best Practices:
- Support multiple output formats (CSV, JSON, HTML, Excel)
- Implement pagination for large datasets
- Use consistent report naming: `ReportType_YYYYMMDD_HHMM.extension`
- Include error handling for API throttling
- Document required Graph API permissions
- Cache data when appropriate to reduce API calls
- Schedule reports during off-peak hours for large environments

#### Example Report Header:
```powershell
<#
.SYNOPSIS
    Generate comprehensive device compliance report

.DESCRIPTION
    Retrieves device compliance status from Intune and generates
    a detailed report in multiple formats

.PARAMETER OutputFormat
    Output format: CSV, JSON, HTML, or Excel (default: CSV)

.PARAMETER OutputPath
    Path to save the report file

.EXAMPLE
    .\Get-DeviceComplianceReport.ps1 -OutputFormat Excel -OutputPath "C:\Reports"

.NOTES
    Author: Your Name
    Date: 2026-02-10
    Version: 1.0
    Prerequisites:
    - Microsoft.Graph.Intune module
    - DeviceManagementManagedDevices.Read.All permission
    - ImportExcel module (for Excel output)
#>
```

### 6. Documentation

- Update the folder's README.md if needed
- Include usage examples in script comments
- Document any dependencies or prerequisites
- Note any known limitations

### 7. Working with Microsoft Graph API

Many scripts across different folders (Cloud, Migration, Reporting, Maintenance) use Microsoft Graph API. Follow these guidelines when working with Graph API:

#### Authentication Methods:
- **App Registration with Certificate** (recommended for production)
- **App Registration with Client Secret** (easier for development)
- **Delegated Permissions** (interactive authentication)

#### Required Permissions:
Document the minimum required Graph API permissions in your script header:
- `DeviceManagementManagedDevices.Read.All` / `ReadWrite.All`
- `DeviceManagementConfiguration.Read.All` / `ReadWrite.All`
- `Directory.Read.All` / `ReadWrite.All`
- `User.Read.All` / `ReadWrite.All`
- `Application.Read.All` / `ReadWrite.All`

#### Graph API Best Practices:
- Use the Microsoft.Graph PowerShell module
- Implement proper error handling for API throttling (429 errors)
- Use pagination for large result sets with `-All` or manual pagination
- Respect API rate limits and implement retry logic
- Use batch requests when making multiple related API calls
- Filter data at the API level rather than in PowerShell when possible
- Cache authentication tokens to reduce authentication overhead
- Use the `-ConsistencyLevel eventual` parameter when using advanced queries

#### Example Graph API Script Structure:
```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Get all devices with pagination
$devices = Get-MgDeviceManagementManagedDevice -All

# Implement error handling for throttling
try {
    $result = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
} catch {
    if ($_.Exception.Response.StatusCode -eq 429) {
        # Handle rate limiting
        Start-Sleep -Seconds 60
        # Retry logic here
    }
}
```

#### When to Place Scripts in GraphAPI Folder:
- Script's primary purpose is Graph API interaction
- Script provides reusable Graph API functions for other scripts
- Script demonstrates advanced Graph API techniques

#### When to Place Graph API Scripts Elsewhere:
- **Cloud/**: Graph API script for cloud-specific device/identity management
- **Migration/**: Graph API script for migration-specific tasks
- **Reporting/**: Graph API script primarily focused on reporting
- **Maintenance/**: Graph API script for ongoing maintenance tasks

### 8. Submission Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/add-script-name`)
3. Add your script to the appropriate folder
4. Update relevant README files
5. Commit your changes (`git commit -am 'Add script for XYZ'`)
6. Push to the branch (`git push origin feature/add-script-name`)
7. Create a Pull Request

## Code Style Guidelines

- Use approved PowerShell verbs (Get-, Set-, New-, Remove-, etc.)
- Use PascalCase for function names
- Use descriptive variable names
- Include comments for complex logic
- Limit line length to 115 characters
- Use 4 spaces for indentation

## Security Considerations

- Never hardcode credentials
- Use secure credential storage methods
- Sanitize user input
- Follow principle of least privilege
- Document required permissions clearly

## Questions?

Open an issue if you have questions about where to place a script or how to contribute.

Thank you for helping make this repository more useful for the community!

# Contributing to Intune-Scripts

Thank you for considering contributing to this repository! This guide will help you add your scripts in the right location.

## How to Contribute

### 1. Choose the Right Folder

Select the appropriate folder based on your script's purpose:

- **Cloud/**: Cloud-based management scripts (Intune, Entra ID, etc.)
- **On-Premises/**: On-premises infrastructure scripts (AD, GPO, SCCM)
- **Migration/**: Scripts specifically for migration phases
- **GraphAPI/**: Scripts that primarily use Microsoft Graph API
- **Maintenance/**: Ongoing maintenance and optimization scripts

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

### 5. Documentation

- Update the folder's README.md if needed
- Include usage examples in script comments
- Document any dependencies or prerequisites
- Note any known limitations

### 6. Submission Process

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

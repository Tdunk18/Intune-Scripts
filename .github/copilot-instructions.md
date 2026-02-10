# Copilot Instructions for Intune-Scripts

## Repository Overview

This repository contains useful scripts for Microsoft Intune during Hybrid and Entra Join (formerly Azure AD Join) migrations. The scripts help IT administrators automate and manage device enrollment, policy deployment, and migration tasks.

**Repository Type:** PowerShell script collection for Microsoft Intune management
**Primary Language:** PowerShell
**Target Platform:** Windows with Microsoft Intune/Endpoint Manager
**License:** GNU General Public License v3.0

## Repository Structure

Currently, the repository is in its initial state with:
- `README.md` - Brief description of the repository's purpose
- `LICENSE` - GNU GPL v3.0 license file

The repository is expected to grow with PowerShell scripts organized by functionality (e.g., device management, policy deployment, migration utilities, reporting).

## Coding Standards and Best Practices

### PowerShell Scripts
- Use PowerShell 5.1+ compatible syntax for maximum compatibility
- Follow PowerShell best practices:
  - Use approved verbs (Get, Set, New, Remove, etc.)
  - Include proper error handling with try-catch blocks
  - Add comment-based help at the beginning of scripts
  - Use explicit parameter types
  - Avoid hardcoded credentials; use secure methods like Get-Credential or environment variables
- Scripts should be well-documented with inline comments explaining complex logic
- Include examples in script headers showing how to use them

### Security Considerations
- Never commit credentials, API keys, or tokens
- Use PowerShell SecureString for sensitive data
- Scripts should validate input parameters
- Include warnings for destructive operations
- Test scripts in a non-production environment first

### File Organization
- Scripts should have descriptive names that indicate their purpose
- Use `.ps1` extension for PowerShell scripts
- Consider organizing scripts into folders by category:
  - Device enrollment/registration
  - Policy management
  - Migration utilities
  - Reporting and auditing
  - Troubleshooting tools

## Development Workflow

### Testing PowerShell Scripts
- Test scripts locally in PowerShell before committing
- Verify syntax: `powershell.exe -NoProfile -Command "& {Get-Command -Syntax 'path/to/script.ps1'}"`
- Use `Test-Path` and other validation cmdlets
- Consider adding Pester tests for critical functionality (if test framework is added)

### Common Commands
Since this is a script repository, there are no build steps. However:
- **Syntax check:** Run `powershell.exe -NoProfile -NoExit -File script.ps1 -WhatIf` to validate
- **Linting:** If PSScriptAnalyzer is added, use `Invoke-ScriptAnalyzer -Path .`
- **Documentation:** Ensure README.md is updated when adding new scripts

## Important Notes for Coding Agents

1. **PowerShell Version Compatibility:** Always ensure scripts are compatible with PowerShell 5.1+ as this is the most common version in enterprise environments. Avoid using PowerShell 7+ exclusive features unless explicitly required.

2. **Microsoft Graph API:** Many Intune operations use Microsoft Graph API. When writing scripts that interact with Intune:
   - Use the Microsoft.Graph PowerShell SDK modules when available
   - Include authentication examples in script documentation
   - Handle API rate limits and throttling

3. **Error Handling:** Intune scripts often run in enterprise environments. Include robust error handling:
   - Use `$ErrorActionPreference = 'Stop'` or try-catch blocks
   - Log errors with meaningful messages
   - Provide rollback options for configuration changes

4. **Documentation Requirements:** Each script should include:
   - Synopsis describing what the script does
   - Description of parameters
   - Examples of usage
   - Prerequisites (required modules, permissions, etc.)
   - Author information and version history

5. **No Build/Test Infrastructure:** This repository doesn't have automated testing or CI/CD pipelines. Manual validation and peer review are the primary quality gates.

6. **README Updates:** When adding new scripts, update the README.md to include:
   - Brief description of the script
   - Use case scenarios
   - Link or reference to the script file

## Validation Steps

Before finalizing changes:
1. Ensure PowerShell scripts have no syntax errors
2. Verify that README.md is updated if new scripts are added
3. Check that no sensitive information (credentials, tenant IDs, etc.) is included
4. Validate that scripts follow PowerShell best practices
5. Ensure proper licensing headers if required

## Additional Context

This repository is designed to help IT administrators during device migration from on-premises/hybrid Active Directory to Entra ID (Azure AD) with Intune management. Scripts may include:
- Device enrollment automation
- Policy migration and deployment
- User data backup/restore
- Compliance checking
- Reporting tools
- Troubleshooting utilities

When creating or modifying scripts, consider the enterprise context and ensure they are production-ready with appropriate safeguards.

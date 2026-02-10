# Copilot Instructions for Intune-Scripts Repository

## Project Overview
This repository contains PowerShell scripts for Microsoft Intune management, specifically focused on Hybrid and Entra Join (formerly Azure AD Join) migrations. The scripts are designed to help IT administrators automate and streamline device management tasks during migration scenarios.

## Technical Stack
- **Primary Language**: PowerShell (5.1 and 7.x compatibility preferred)
- **Target Platform**: Windows devices managed by Microsoft Intune
- **Related Technologies**: Microsoft Graph API, Azure AD/Entra ID, Windows Management Instrumentation (WMI)

## Coding Standards

### PowerShell Best Practices
1. **Script Structure**
   - Use approved PowerShell verbs (Get-, Set-, New-, Remove-, etc.)
   - Include proper comment-based help at the beginning of each script
   - Use `[CmdletBinding()]` for advanced function features
   - Include parameter validation attributes where appropriate

2. **Naming Conventions**
   - Use PascalCase for function names and parameters
   - Use descriptive variable names that explain their purpose
   - Prefix script names with the area they address (e.g., `Migration-`, `Entra-`, `Device-`)

3. **Error Handling**
   - Always use Try-Catch blocks for operations that may fail
   - Include meaningful error messages
   - Use `-ErrorAction Stop` for critical operations
   - Log errors appropriately for troubleshooting

4. **Code Quality**
   - Follow the PowerShell Script Analyzer (PSScriptAnalyzer) guidelines
   - Keep functions focused on a single responsibility
   - Avoid hardcoded credentials or sensitive information
   - Use secure string handling for credentials when necessary

5. **Comments and Documentation**
   - Include inline comments for complex logic
   - Document all parameters with descriptions
   - Add examples in comment-based help
   - Explain any workarounds or non-obvious implementations

### Security Considerations
- **Never** hardcode credentials, API keys, or tenant IDs in scripts
- Use secure credential storage mechanisms (e.g., Azure Key Vault, Windows Credential Manager)
- Validate and sanitize all user inputs
- Follow the principle of least privilege for API permissions
- Include warnings about required permissions in script documentation

### Microsoft Intune Specific Guidelines
1. **Graph API Usage**
   - Use Microsoft Graph PowerShell SDK when available
   - Include proper authentication handling
   - Implement proper pagination for large result sets
   - Handle throttling and rate limiting gracefully

2. **Device Management**
   - Consider offline devices and retry logic
   - Validate device state before making changes
   - Include rollback procedures where applicable
   - Log all device modifications for audit purposes

3. **Migration Scripts**
   - Clearly document prerequisites (e.g., required permissions, modules)
   - Include validation checks before performing migrations
   - Provide progress indicators for long-running operations
   - Create backup/restore capabilities where appropriate

## Documentation Requirements

### README Updates
- Keep the main README.md updated with a list of available scripts
- Include a brief description of each script's purpose
- Document required permissions for each script
- Provide usage examples

### Script Documentation
Each script should include:
- **Synopsis**: Brief description of what the script does
- **Description**: Detailed explanation of functionality
- **Parameters**: Description of all parameters including required vs. optional
- **Examples**: At least one usage example
- **Prerequisites**: Required modules, permissions, or configurations
- **Notes**: Any important information about limitations or considerations

### Change Documentation
- Document breaking changes in scripts
- Note version compatibility requirements
- Explain migration paths for deprecated functionality

## Testing Guidelines

### Manual Testing
- Test scripts in a non-production environment first
- Validate against different device types and configurations
- Test error handling with various failure scenarios
- Verify logging and output are appropriate

### Script Validation
- Run PSScriptAnalyzer on all PowerShell scripts
- Address all warnings and errors before committing
- Test with both PowerShell 5.1 and PowerShell 7.x when possible

## Version Control Practices
- Use descriptive commit messages
- Reference issue numbers in commits when applicable
- Keep commits focused on single logical changes
- Don't commit sensitive information (credentials, tenant IDs, etc.)

## Dependencies and Modules
When adding dependencies:
- Document required PowerShell modules in script comments
- Specify minimum version requirements
- Include installation instructions in script documentation
- Consider using `#Requires` statements for critical dependencies

## Performance Considerations
- Optimize for bulk operations when processing multiple devices
- Use efficient filtering at the API level rather than in PowerShell
- Implement appropriate caching for frequently accessed data
- Consider memory usage for large datasets

## Contribution Guidelines
- Ensure scripts are well-tested before submitting
- Follow all coding standards outlined above
- Update documentation alongside code changes
- Add examples demonstrating script usage
- Consider edge cases and error scenarios

## Special Notes for Copilot
- Prioritize security and never include sensitive information in code
- Always include proper error handling and logging
- When creating new scripts, follow the established naming and structure patterns
- Consider backward compatibility with existing Intune configurations
- Be mindful of API rate limits and implement appropriate throttling

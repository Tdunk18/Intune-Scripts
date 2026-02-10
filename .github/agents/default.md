# Copilot Code Agent Instructions

## Repository Context
This repository contains useful Intune scripts designed to assist with Hybrid and Entra Join Migrations. The scripts help IT administrators manage device migrations and configurations in Microsoft Intune environments.

## Code Standards and Guidelines

### PowerShell Scripts
- Follow PowerShell best practices and naming conventions
- Use approved verbs (Get, Set, New, Remove, etc.)
- Include proper error handling with try/catch blocks
- Add comment-based help headers to all scripts
- Use meaningful variable names with proper casing (PascalCase for parameters, camelCase for local variables)
- Avoid hardcoded values; use parameters instead

### Documentation
- Keep README.md up to date with any new scripts or functionality
- Document script parameters, requirements, and usage examples
- Include prerequisites (required modules, permissions, etc.)
- Provide clear descriptions of what each script does

### Security
- Never hardcode credentials or sensitive information
- Use secure credential handling (Get-Credential, Azure Key Vault, etc.)
- Validate all user inputs
- Follow principle of least privilege

### Testing
- Test scripts in a non-production environment first
- Verify scripts work with different Windows versions if applicable
- Consider edge cases and error scenarios

## File Organization
- Keep scripts organized by function or purpose
- Use clear, descriptive filenames
- Include version information or dates in script headers when appropriate

## When Working on This Repository
1. Understand the context: These scripts are used in production IT environments
2. Prioritize reliability and safety over convenience
3. Maintain backward compatibility when possible
4. Add appropriate logging for troubleshooting
5. Consider the impact on end users and devices

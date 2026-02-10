# Intune-Scripts

A list of useful Intune scripts during your Hybrid and Entra Join Migrations.

## Script Requirements

All scripts in this repository must follow the standards and requirements outlined in [SCRIPT_REQUIREMENTS.md](SCRIPT_REQUIREMENTS.md). This ensures consistency, security, and maintainability across all scripts.

### Key Requirements

- **Authentication**: Microsoft Entra ID authentication with MFA support
- **Permissions**: Properly documented delegated permissions
- **Design**: Idempotent, modular scripts with robust error handling
- **Logging**: Dual logging (portable + Intune service locations) with no sensitive data
- **Output**: Standardized formats (CSV/JSON)

For complete details, please review the [SCRIPT_REQUIREMENTS.md](SCRIPT_REQUIREMENTS.md) document. 

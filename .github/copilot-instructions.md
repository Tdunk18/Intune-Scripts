# Copilot Instructions for Intune-Scripts Repository

This repository contains useful Intune scripts for Hybrid and Entra Join Migrations. When working with this repository, follow these guidelines to ensure high-quality, secure, and maintainable PowerShell scripts.

## 1. Authentication and Permissions

- **Azure AD Authentication**: Scripts should implement Azure AD authentication for secure access to Microsoft Graph and Intune APIs via the Microsoft.Graph PowerShell module (the legacy Microsoft.Graph.Intune module is deprecated).
- **Delegated Permissions**: Verify that proper user delegated permissions are in place for the Intune service.
- **MFA Compliance**: Ensure compatibility with multi-factor authentication (MFA).
- **Token Caching**: Optionally provide token caching for session persistence.

## 2. Script Design Principles

- **Idempotency**: Each script should be idempotent to avoid duplicating objects or creating configuration conflicts in Intune.
- **Modularity**: Separate tasks (e.g., app management, device configuration, and reporting) into different script modules for better adaptability and reuse.
- **Error Handling**: Include robust error trapping with try/catch/finally blocks and meaningful error messages.
- **Logging and Auditing**:
  - Write detailed logs (with timestamps) to help trace script execution and facilitate debugging.
  - Ensure sensitive information (e.g., tokens, PII, credentials) is not logged.
  - Ensure two sets of logs are created: local logs in the script's directory for immediate troubleshooting and logs in Intune's diagnostics directory (e.g., C:\ProgramData\Microsoft\IntuneManagementExtension\Logs) that can be collected by Intune's collect diagnostics system.
  - Ensure logs always default to verbose logging and use the file name of the script as its log file name.
  - Implement log rotation to prevent log file creep: append to log files with timestamps for each execution, and implement a retention policy (e.g., keep logs for up to 30 days AND limit total size to 10MB, whichever limit is reached first) with automatic cleanup of old entries.
- **Output Standardization**: Provide uniform outputs such as CSV or JSON that users can parse for further use.

## 3. Device and Policy Management

- **Device Scope**: Allow users to select device types (e.g., iOS, Android, macOS, Windows) for policy application.
- **Policy Assignment**: Scripts should handle policy assignments (e.g., compliance, configuration, app protection) to specific groups.
- **Pilot-Friendly Implementation**: Include options to test scripts on pilot groups before large-scale deployment.
- **Rollback Plans**: Offer clear rollback procedures if issues arise during changes or migrations.

## 4. Validation and Reporting

- **Pre-migration Checks**:
  - Validate device readiness (e.g., if co-managed or hybrid AD-joined devices can be migrated).
  - Check user licensing (e.g., ensure users have Intune licenses).
- **Migration Reporting**:
  - Provide pre- and post-migration reports (e.g., devices migrated, compliance status, errors encountered).
  - Give users analytics on the status of migrated devices, such as current compliance states.
- **Dependency Validation**: Check for and report dependencies (e.g., app prerequisites, configurations).

## 5. Graph API Integration

- **Microsoft Graph Support**: Use Microsoft Graph API for interacting with Intune, leveraging the Microsoft.Graph PowerShell module.
- **OData Querying**: Implement OData querying for fetching filtered data efficiently (e.g., $filter, $expand, $select).
- **Rate Limiting and Retries**: Handle Graph API throttling by including retry logic with exponential backoff (recommended: maximum 5 retry attempts with backoff starting at 1 second and doubling each time, e.g., 1s, 2s, 4s, 8s, 16s).

## 6. Ease of Use and Customization

- **User Inputs**:
  - Supply parameterized scripts with well-documented default values.
  - Offer clear prompts or validated input (e.g., group selection, device targets).
- **Intune Tenancy Detection**: Automatically detect the organization's Intune tenant setup.
- **Documentation**: Accompany scripts with detailed inline comments and examples.
- **Cross-Platform Execution**: Ensure scripts can run on Windows, macOS, and Linux (if applicable).

## 7. Security Best Practices

- **Encryption**: Encrypt sensitive values (e.g., for app configuration secrets or certificates) during storage and use.
- **Execution Policies**: Warn users about the required PowerShell execution policy (e.g., RemoteSigned).
- **Approval Controls**: Include interim approval prompts for critical or destructive actions only if script is designed with interactive controls.
- **Credential Handling**:
  - Use secure credential prompts (e.g., Get-Credential).
  - Avoid plaintext passwords or secrets in scripts.

## 8. Compliance and Governance

- **Audit Compliance**: Scripts should respect organizational compliance policies, e.g., device naming conventions, security baselines, and conditional access practices.
- **Audit Logs**: Log crucial script actions to Azure Monitor or Storage accounts.
- **Retention and Disposal**: Implement cleanup code for temporary data or files.

## 9. Templates and Libraries

- **Configuration-as-Code**: Provide libraries or templates for common actions, e.g., importing device lists, configuring profiles, or deploying Defender policies.
- **Community-Friendly Design**: Make the library discoverable and equivalent to a PowerShell module for shared use, with facilities for contributors to extend functionality.

## 10. Scalability

- **Batch Processing**: Enable parallel processing for large workloads.
- **Rate Control**: Allow the user to control script execution rates to prevent overloading the service.
- **Bulk Actions**: Support migrating multiple users, groups, or devices in a single run.

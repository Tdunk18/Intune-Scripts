# Cloud Scripts

This folder contains scripts for cloud-based device and identity management using Microsoft Intune and related cloud services.

## Subfolders

### Intune-Management
Scripts for managing devices, applications, and configurations through Microsoft Intune.
- Device enrollment scripts
- Application deployment
- Configuration profiles
- Update management

### Entra-ID
Scripts for managing Azure Active Directory (Entra ID) operations.
- User and group management
- Device registration
- Identity synchronization
- Hybrid join configurations

### Conditional-Access
Scripts for managing conditional access policies.
- Policy creation and updates
- Compliance checks
- Access control configurations

### Compliance-Policies
Scripts for device compliance policy management.
- Compliance policy deployment
- Compliance reporting
- Remediation scripts

## Usage

These scripts are designed for organizations that have migrated or are operating in a cloud-first environment. They interact with Microsoft Graph API and Azure services.

## Prerequisites

- Azure AD/Entra ID tenant
- Microsoft Intune licenses
- Appropriate Graph API permissions
- PowerShell modules:
  - Microsoft.Graph
  - Az modules (where applicable)

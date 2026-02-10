# Graph API Scripts

This folder contains scripts that interact with Microsoft Graph API for managing Intune and Azure AD resources.

## Subfolders

### Device-Management
Scripts for device operations via Graph API.
- Device inventory and reporting
- Device compliance queries
- Remote actions (wipe, retire, sync)
- Device configuration retrieval
- Bulk device operations

### User-Management
Scripts for user and identity operations.
- User provisioning
- License assignment
- User device association
- User group membership
- Authentication methods

### App-Management
Scripts for application management.
- Application deployment
- App protection policies
- App configuration policies
- App inventory and reporting

### Policy-Management
Scripts for managing various policies.
- Configuration policies
- Compliance policies
- Conditional access policies
- Policy assignment and targeting
- Policy backup and restore

### Reporting
Scripts for generating reports and analytics.
- Compliance reports
- Inventory reports
- Usage analytics
- Audit logs
- Custom dashboards

## Authentication

All scripts in this folder require proper Graph API authentication. Common methods:
- App Registration with Certificate
- App Registration with Client Secret
- Delegated Permissions (Interactive)

## Required Permissions

Ensure your app registration or user account has the appropriate Graph API permissions:
- DeviceManagementManagedDevices.ReadWrite.All
- DeviceManagementConfiguration.ReadWrite.All
- Directory.ReadWrite.All
- User.ReadWrite.All
- Application.ReadWrite.All

## Prerequisites

- PowerShell modules:
  - Microsoft.Graph
  - MSAL.PS (for some authentication scenarios)

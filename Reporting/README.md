# Reporting Scripts

This folder contains scripts for generating comprehensive reports across your Intune and Azure environment.

## Overview

The Reporting section provides scripts to extract, analyze, and present data from various sources including Intune, Azure AD, and related services. These scripts help with compliance tracking, auditing, inventory management, and executive reporting.

## Subfolders

### Compliance-Reports
Scripts for generating compliance-related reports.
- Device compliance status reports
- Policy compliance tracking
- Non-compliant device reports
- Compliance trends and analytics
- Regulatory compliance documentation

### Device-Reports
Scripts for device inventory and status reporting.
- Complete device inventory reports
- Device health status
- Operating system distribution
- Hardware inventory
- Device lifecycle reporting
- Enrollment status reports

### User-Reports
Scripts for user-related reporting.
- User device assignments
- License utilization reports
- User adoption and activity
- User authentication reports
- User compliance status

### Application-Reports
Scripts for application deployment and usage reporting.
- Application inventory reports
- App deployment status
- App installation success/failure rates
- App usage analytics
- License compliance for apps

### Security-Reports
Scripts for security posture and threat reporting.
- Security baseline compliance
- Threat detection reports
- BitLocker encryption status
- Security policy effectiveness
- Vulnerability assessments
- Conditional access reports

### Custom-Reports
Scripts for custom and executive-level reporting.
- Executive dashboards
- Custom KPI reports
- Multi-tenant reports
- Cost analysis reports
- Change management reports

## Common Use Cases

1. **Executive Reporting**: High-level dashboards for leadership
2. **Compliance Audits**: Detailed compliance reports for auditors
3. **Inventory Management**: Device and application tracking
4. **Security Posture**: Security status and risk assessment
5. **Operational Metrics**: Day-to-day operational reporting

## Report Formats

Scripts should support multiple output formats:
- **CSV**: For Excel import and data manipulation
- **JSON**: For programmatic processing and APIs
- **HTML**: For web-based viewing and dashboards
- **PDF**: For formal documentation and distribution
- **Excel**: Native Excel workbooks with charts

## Data Sources

Reports may pull data from:
- Microsoft Graph API
- Azure AD/Entra ID
- Microsoft Intune
- Microsoft Defender for Endpoint
- Azure Log Analytics
- Configuration Manager (hybrid scenarios)

## Best Practices

1. **Scheduling**: Run reports during off-peak hours
2. **Pagination**: Use pagination for large datasets
3. **Caching**: Implement caching for frequently accessed data
4. **Archiving**: Archive old reports with timestamp
5. **Security**: Ensure reports don't expose sensitive data
6. **Performance**: Optimize queries for large environments

## Prerequisites

- Microsoft Graph API permissions
- PowerShell modules:
  - Microsoft.Graph
  - ImportExcel (for Excel reports)
  - PSWriteHTML (for HTML reports)
- Appropriate read permissions for data sources
- Storage location for report output

## Report Naming Convention

Use consistent naming for reports:
```
ReportType_YYYYMMDD_HHMM.extension
Example: DeviceInventory_20260210_0900.xlsx
```

## Automation

Consider automating reports:
- Use Azure Automation for scheduled runs
- Implement Power Automate for distribution
- Set up email notifications for critical reports
- Use Azure Functions for on-demand reports

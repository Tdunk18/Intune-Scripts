# Reporting Scripts

This folder contains scripts for generating reports and analytics from your Intune environment.

## Purpose

Scripts in this folder use Graph API to:
- Generate compliance reports
- Create device inventory reports
- Analyze usage and adoption
- Extract audit logs
- Build custom dashboards

## Example Scripts

Place scripts here such as:
- `Get-ComplianceReport.ps1` - Device compliance status report
- `Get-DeviceInventoryReport.ps1` - Comprehensive device inventory
- `Get-ApplicationReport.ps1` - App deployment and usage report
- `Get-UserDeviceReport.ps1` - User-to-device mapping report
- `Export-AuditLogs.ps1` - Export Intune audit logs
- `Get-PolicyAssignmentReport.ps1` - Policy assignment coverage
- `Get-NonCompliantDevices.ps1` - Report on non-compliant devices

## Report Formats

Scripts should support multiple output formats:
- CSV for Excel import
- JSON for programmatic processing
- HTML for web viewing
- PDF for distribution (where applicable)

## Graph API Endpoints Used

- `/deviceManagement/managedDevices`
- `/deviceManagement/deviceCompliancePolicies`
- `/deviceManagement/reports`
- `/auditLogs/directoryAudits`

## Required Permissions

- DeviceManagementManagedDevices.Read.All
- DeviceManagementConfiguration.Read.All
- DeviceManagementApps.Read.All
- AuditLog.Read.All (for audit logs)

## Best Practices

1. Schedule reports to run during off-peak hours
2. Use pagination for large datasets
3. Implement caching for frequently accessed data
4. Include timestamp in report filenames
5. Archive old reports regularly

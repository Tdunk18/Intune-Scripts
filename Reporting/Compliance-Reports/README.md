# Compliance Reports

This folder contains scripts for generating compliance-related reports across your Intune environment.

## Purpose

Scripts in this folder help with:
- Tracking device compliance status
- Monitoring policy compliance
- Identifying non-compliant devices
- Generating audit reports
- Compliance trend analysis

## Example Scripts

Place scripts here such as:
- `Get-DeviceComplianceReport.ps1` - Overall device compliance status
- `Get-NonCompliantDevices.ps1` - Detailed non-compliant device report
- `Get-ComplianceTrends.ps1` - Historical compliance trends
- `Get-PolicyComplianceReport.ps1` - Policy-by-policy compliance
- `Export-ComplianceAuditReport.ps1` - Audit-ready compliance documentation
- `Get-ComplianceByPlatform.ps1` - Compliance breakdown by OS
- `Get-ComplianceRemediationReport.ps1` - Remediation actions taken

## Report Types

### Device Compliance Reports
- Overall compliance percentage
- Compliant vs. non-compliant device counts
- Compliance status by device type
- Compliance trends over time

### Policy Compliance Reports
- Which policies have the highest non-compliance rates
- Policy effectiveness analysis
- Common compliance failures

### Remediation Reports
- Actions taken to remediate non-compliance
- Remediation success rates
- Time to remediation metrics

## Key Metrics

Track these compliance metrics:
- Overall compliance percentage
- Non-compliance reasons breakdown
- Time to compliance after enrollment
- Compliance by department/group
- Compliance by OS version

## Regulatory Considerations

For regulated industries, ensure reports include:
- Timestamp and audit trail
- User who generated the report
- Data retention compliance
- Privacy considerations
- Export controls for sensitive data

## Recommended Schedule

- **Daily**: Quick compliance dashboard
- **Weekly**: Detailed compliance reports for IT
- **Monthly**: Executive compliance summary
- **Quarterly**: Comprehensive audit reports

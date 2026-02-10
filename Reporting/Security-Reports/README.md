# Security Reports

This folder contains scripts for security posture and threat reporting across your Intune environment.

## Purpose

Scripts in this folder help with:
- Security baseline compliance tracking
- Threat and vulnerability reporting
- Encryption status monitoring
- Security policy effectiveness
- Risk assessment and mitigation

## Example Scripts

Place scripts here such as:
- `Get-SecurityBaselineReport.ps1` - Security baseline compliance
- `Get-BitLockerStatusReport.ps1` - BitLocker encryption status
- `Get-ThreatDetectionReport.ps1` - Threat detection summary
- `Get-VulnerabilityReport.ps1` - Known vulnerabilities across devices
- `Get-ConditionalAccessReport.ps1` - Conditional access policy usage
- `Get-SecurityPolicyReport.ps1` - Security policy deployment status
- `Get-RiskScoreReport.ps1` - Device and user risk scores
- `Get-DefenderStatusReport.ps1` - Microsoft Defender status

## Report Categories

### Baseline Compliance
- Security baseline deployment status
- Configuration drift from baseline
- Non-compliant security settings
- Baseline version tracking

### Encryption Status
- BitLocker encryption coverage
- Encryption key escrow status
- Unencrypted device identification
- Recovery key availability

### Threat Detection
- Active threats detected
- Quarantined items
- Threat trends over time
- High-risk devices

### Vulnerability Assessment
- Known CVEs on devices
- Patch compliance status
- Software vulnerabilities
- Remediation recommendations

### Conditional Access
- Policy hit rate and effectiveness
- Blocked sign-in attempts
- MFA adoption and usage
- Device compliance impact on access

## Key Security Metrics

Track these critical security metrics:
- Percentage of encrypted devices
- Security baseline compliance rate
- Active threat count
- Mean time to remediate vulnerabilities
- MFA adoption rate
- Conditional access policy coverage
- Device risk score distribution

## Compliance Frameworks

Align reports with frameworks:
- CIS Benchmarks
- NIST Cybersecurity Framework
- ISO 27001
- PCI DSS
- HIPAA
- SOC 2

## Alert Thresholds

Set thresholds for security alerts:
- Encryption compliance below 95%
- Baseline compliance below 90%
- Active threats on any device
- High-risk users or devices
- Failed sign-ins above threshold

## Recommended Schedule

- **Real-time**: Critical threat alerts
- **Daily**: Threat detection and risk scores
- **Weekly**: Vulnerability and encryption status
- **Monthly**: Comprehensive security posture
- **Quarterly**: Executive security summary

## Best Practices

1. **Sensitive Data**: Protect security reports appropriately
2. **Access Control**: Limit access to security team
3. **Retention**: Follow data retention policies
4. **Trending**: Track metrics over time
5. **Actionable**: Include remediation steps
6. **Integration**: Feed data to SIEM if available

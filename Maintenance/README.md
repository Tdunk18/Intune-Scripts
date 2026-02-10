# Maintenance Scripts

This folder contains scripts for ongoing maintenance and optimization of your Intune environment.

## Subfolders

### Cleanup
Scripts for cleaning up and removing unused resources.
- Stale device removal
- Orphaned object cleanup
- Unused policy removal
- License optimization
- Autopilot device cleanup

### Monitoring
Scripts for monitoring environment health.
- Service health checks
- Device compliance monitoring
- Policy deployment status
- Sync status monitoring
- Alert generation

### Audit
Scripts for auditing and compliance tracking.
- Change tracking
- Access reviews
- Policy compliance audits
- Security baseline checks
- Configuration drift detection

### Optimization
Scripts for optimizing performance and configuration.
- Policy consolidation
- Group optimization
- Performance tuning
- Best practice recommendations
- Cost optimization

## Recommended Schedule

- **Daily**: Device sync status, compliance monitoring
- **Weekly**: Stale device cleanup, health checks
- **Monthly**: Policy audits, optimization reviews, access reviews
- **Quarterly**: Full environment assessment, cost optimization

## Prerequisites

- Established baseline configurations
- Monitoring thresholds defined
- Retention policies documented
- PowerShell modules:
  - Microsoft.Graph
  - Az.Monitor (for some scenarios)

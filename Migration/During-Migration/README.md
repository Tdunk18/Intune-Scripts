# During Migration Scripts

This folder contains scripts to use during the active migration process from on-premises to Intune.

## Purpose

Scripts in this folder help with:
- Device transition automation
- Co-management configuration
- Phased rollout execution
- User communication
- Migration monitoring
- Issue remediation during migration

## Example Scripts

Place scripts here such as:
- `Enable-CoManagement.ps1` - Configure co-management for pilot devices
- `Transition-DeviceToIntune.ps1` - Move device from SCCM to Intune
- `Deploy-IntuneClient.ps1` - Install and configure Intune client
- `Monitor-MigrationProgress.ps1` - Track migration status
- `Send-UserNotification.ps1` - Notify users about migration
- `Fix-EnrollmentIssues.ps1` - Remediate common enrollment problems
- `Rollback-Device.ps1` - Rollback device to previous state

## Migration Phases

### Phase 1: Pilot Group (10-100 devices)
- Test all configurations with pilot users
- Monitor closely for issues
- Gather feedback
- Adjust policies as needed

### Phase 2: Phased Rollout (Wave-based)
- Deploy to departments or locations in waves
- Allow time between waves for issue resolution
- Scale monitoring and support

### Phase 3: Mass Migration
- Accelerate rollout to remaining devices
- Automated remediation
- Bulk operations

## Monitoring During Migration

Track these key metrics:
- Enrollment success rate
- Policy application success
- User reported issues
- Device compliance status
- Network and service health

## Rollback Procedures

Always have rollback plans:
- Document pre-migration state
- Keep on-premises infrastructure active
- Test rollback procedures
- Define rollback criteria
- Communicate rollback process

## Co-Management Workloads

Typical migration order:
1. Compliance policies
2. Resource access policies
3. Device configuration
4. Windows Update policies
5. Endpoint Protection
6. Client apps
7. Office Click-to-Run apps

## Best Practices

1. **Start Small**: Begin with pilot group
2. **Monitor Closely**: Watch for issues in real-time
3. **Communicate**: Keep users informed
4. **Document**: Record all issues and resolutions
5. **Be Patient**: Allow time between phases
6. **Support Ready**: Ensure helpdesk is prepared

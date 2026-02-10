# Migration Scripts

This folder contains scripts to facilitate the migration from on-premises or hybrid management to cloud-based Intune management.

## Subfolders

### Pre-Migration
Scripts to run before starting the migration process.
- Environment assessment
- Readiness checks
- Inventory collection
- Dependency mapping
- Backup and documentation

### During-Migration
Scripts to use during active migration.
- Device transition scripts
- User communication and notification
- Phased rollout automation
- Co-management configuration
- Migration monitoring

### Post-Migration
Scripts to run after migration completion.
- Cleanup of legacy resources
- Validation of cloud configurations
- Decommissioning on-premises infrastructure
- Final reporting

### Validation
Scripts for validating migration success.
- Device enrollment verification
- Policy application checks
- User access validation
- Compliance verification
- Performance testing

## Migration Phases

1. **Assessment & Planning** - Use Pre-Migration scripts
2. **Pilot** - Begin with During-Migration scripts on test group
3. **Rollout** - Expand using During-Migration scripts
4. **Validation** - Run Validation scripts
5. **Optimization** - Use Post-Migration and Maintenance scripts

## Prerequisites

- Both on-premises and cloud access
- Migration plan documented
- Pilot group identified
- Rollback procedures defined

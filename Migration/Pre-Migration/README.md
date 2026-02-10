# Pre-Migration Scripts

This folder contains scripts to run before starting your migration to Intune.

## Purpose

Pre-migration scripts help you:
- Assess your current environment
- Identify potential issues before migration
- Collect inventory of devices, users, and policies
- Document dependencies
- Validate prerequisites

## Example Scripts

Place scripts here such as:
- `Assess-Environment.ps1` - Complete environment assessment
- `Check-Prerequisites.ps1` - Validate Intune prerequisites
- `Get-DeviceInventory.ps1` - Inventory all managed devices
- `Get-PolicyInventory.ps1` - Document all GPOs and policies
- `Test-NetworkRequirements.ps1` - Verify network connectivity
- `Backup-CurrentConfig.ps1` - Backup existing configurations
- `Map-Dependencies.ps1` - Identify app and policy dependencies

## Recommended Workflow

1. Run environment assessment
2. Check all prerequisites
3. Collect comprehensive inventory
4. Document dependencies and mappings
5. Create backup of current state
6. Review results and create migration plan

## Key Considerations

- Run during off-peak hours for accurate inventory
- Document all findings
- Identify pilot group candidates
- Plan for exceptions and special cases
- Establish baseline metrics for comparison

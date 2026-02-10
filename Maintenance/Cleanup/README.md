# Cleanup Scripts

This folder contains scripts for cleaning up and removing unused resources from your Intune environment.

## Purpose

Scripts in this folder help with:
- Removing stale or inactive devices
- Cleaning up orphaned objects
- Removing unused policies
- Optimizing license assignments
- Maintaining a clean environment

## Example Scripts

Place scripts here such as:
- `Remove-StaleDevices.ps1` - Remove devices inactive for X days
- `Remove-OrphanedDevices.ps1` - Clean up devices without users
- `Remove-UnusedPolicies.ps1` - Remove policies with no assignments
- `Cleanup-AutopilotDevices.ps1` - Remove old Autopilot registrations
- `Optimize-Licenses.ps1` - Remove unused license assignments
- `Remove-DuplicateDevices.ps1` - Clean up duplicate device registrations

## Best Practices

1. **Test First**: Always run in report mode before deletion
2. **Backup**: Export objects before deletion
3. **Schedule**: Run cleanup during maintenance windows
4. **Retention**: Follow your organization's retention policies
5. **Audit**: Log all cleanup operations

## Recommended Schedule

- **Daily**: Identify stale devices (report only)
- **Weekly**: Remove devices inactive for 90+ days
- **Monthly**: Full cleanup review and execution
- **Quarterly**: Policy and license optimization

## Safety Considerations

- Use `-WhatIf` parameter for testing
- Implement approval workflows for bulk deletions
- Keep audit logs of cleanup operations
- Define clear retention criteria

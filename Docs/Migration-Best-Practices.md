# Migration Best Practices

## Overview

This guide provides best practices for using the IntuneScripts module to perform successful device migrations with minimal risk and maximum success rate.

## Pre-Migration Planning

### 1. Inventory and Assessment

**Always start with a comprehensive inventory:**

```powershell
# Connect to Graph
Connect-IntuneGraph

# Get current device inventory
$devices = Get-IntuneDevicesByScope -DeviceType All -IncludeCompliance

# Export to CSV for analysis
$devices | Export-Csv -Path "DeviceInventory.csv" -NoTypeInformation
```

**Analyze the data:**
- Group devices by OS type and version
- Identify non-compliant devices
- Check for stale devices (not synced recently)
- Review enrollment types

### 2. Validate Prerequisites

**Device Readiness:**
```powershell
# Check all Windows devices
$readiness = Test-DeviceReadiness -DeviceType Windows

# Review results
$notReady = $readiness | Where-Object { -not $_.IsReady }
$notReady | Export-Csv -Path "DevicesNotReady.csv" -NoTypeInformation
```

**User Licensing:**
```powershell
# Check target group licensing
$licensing = Test-UserLicensing -GroupId "target-group-id"

# Identify unlicensed users
$unlicensed = $licensing | Where-Object { -not $_.HasIntuneLicense }
```

### 3. Create Baseline Reports

**Always generate a pre-migration baseline:**

```powershell
$preReport = Export-PreMigrationReport -DeviceType Windows -OutputPath ".\Reports"
```

This baseline will be used for:
- Comparison after migration
- Success rate calculation
- Issue identification

## Migration Strategy

### 1. Phased Rollout

**Never migrate all devices at once. Use a phased approach:**

**Phase 1: Pilot (1-5% of devices)**
```powershell
# Create pilot group with 5% of users
$pilotGroup = New-PilotGroup -GroupName "Migration-Pilot-Phase1"

# Test deployment
Test-PilotDeployment -PolicyId $policyId -PolicyType Compliance -PilotGroupId $pilotGroup.id
```

**Phase 2: Early Adopters (5-20%)**
```powershell
# Expand to early adopters after successful pilot
$earlyAdopterGroups = @("Early-Adopters-IT", "Early-Adopters-Business")
```

**Phase 3: Production Rollout (20-100%)**
```powershell
# Gradual rollout to all users
$productionGroups = @("All-Users-Wave1", "All-Users-Wave2", "All-Users-Wave3")
```

### 2. Wait Times Between Phases

**Recommended wait times:**
- Pilot to Early Adopters: 3-7 days
- Early Adopters to Production Wave 1: 5-7 days
- Between Production Waves: 2-3 days

**Monitor during wait periods:**
```powershell
# Daily compliance checks
Get-ComplianceReport -DeviceType Windows -OutputPath ".\Daily-Reports"

# Check for issues
$devices = Get-IntuneDevicesByScope -DeviceType Windows
$issues = $devices | Where-Object { $_.complianceState -eq 'noncompliant' }
```

### 3. Communication Plan

**Before each phase:**
1. Notify affected users
2. Provide timeline and expectations
3. Share support contact information
4. Document known issues and workarounds

## Risk Mitigation

### 1. Always Create Rollback Plans

**Before any changes:**
```powershell
$rollbackPlan = New-RollbackPlan `
    -PolicyIds @($policy1, $policy2, $policy3) `
    -PolicyType Compliance `
    -OutputPath ".\Rollback" `
    -Description "Q1 2026 Windows Migration"
```

**What gets backed up:**
- Current policy configurations
- Policy assignments
- Group memberships
- Rollback procedures (auto-generated)

### 2. Test Rollback Procedures

**Before production migration:**
```powershell
# In a test environment, verify rollback works
Restore-PolicyConfiguration -BackupFile "PolicyBackup_Compliance_test_20260210-120000.json"
```

### 3. Define Success Criteria

**Before starting migration, define what success looks like:**

- Minimum compliance rate: 90%
- Maximum acceptable issues: 5%
- Required metrics:
  - Device sync success rate
  - Policy application rate
  - User satisfaction score

## Monitoring and Validation

### 1. Real-Time Monitoring

**During migration, monitor:**

```powershell
# Every 4-6 hours during active migration
$complianceReport = Get-ComplianceReport -DeviceType Windows

# Check for new issues
$devices = Get-IntuneDevicesByScope -DeviceType Windows
$newIssues = $devices | Where-Object { 
    $_.complianceState -eq 'noncompliant' -or 
    $_.managementState -ne 'managed' 
}
```

### 2. Daily Reports

**Generate daily reports during migration:**

```powershell
# Automated daily report
$date = Get-Date -Format 'yyyyMMdd'
Get-MigrationReport `
    -DeviceType Windows `
    -Format HTML `
    -OutputPath ".\Reports\Daily-$date.html"
```

### 3. Issue Tracking

**Track and categorize issues:**

```powershell
# Export issues for tracking
$issues = Test-DeviceReadiness -DeviceType Windows | 
    Where-Object { -not $_.IsReady }

$issues | Select-Object DeviceName, OperatingSystem, @{
    Name='IssueCount'; Expression={ $_.Issues.Count }
}, @{
    Name='Issues'; Expression={ $_.Issues -join '; ' }
} | Export-Csv -Path "Issues-$date.csv" -NoTypeInformation
```

## Post-Migration

### 1. Generate Comparison Reports

**After migration completes:**

```powershell
$postReport = Export-PostMigrationReport `
    -PreMigrationReportPath $preReport `
    -DeviceType Windows `
    -OutputPath ".\Reports"
```

**Analyze results:**
- Success rate vs. target
- Issues encountered
- Devices still pending
- Compliance improvements

### 2. Cleanup

**After successful migration:**

```powershell
# Remove pilot groups (if no longer needed)
# Archive reports
# Document lessons learned
```

**Keep:**
- Rollback plans (for at least 30 days)
- Migration reports (permanently)
- Issue logs (for reference)

### 3. Documentation

**Document:**
- Final success metrics
- Issues encountered and resolutions
- Lessons learned
- Recommendations for future migrations

## Common Pitfalls to Avoid

### 1. Skipping Pre-Migration Validation

❌ **Don't:**
```powershell
# Don't skip validation
Expand-PilotToProduction -PolicyId $id -PolicyType Compliance -ProductionGroupIds $groups
```

✅ **Do:**
```powershell
# Always validate first
$readiness = Test-DeviceReadiness -DeviceType Windows
$dependencies = Test-Dependencies -PolicyId $id -PolicyType Compliance
# Then proceed if validation passes
```

### 2. Not Creating Rollback Plans

❌ **Don't:**
```powershell
# Don't make changes without backup
New-PolicyAssignment -PolicyId $id -GroupId $group
```

✅ **Do:**
```powershell
# Always backup first
$backup = Backup-PolicyConfiguration -PolicyId $id -PolicyType Compliance
New-PolicyAssignment -PolicyId $id -GroupId $group
```

### 3. Moving Too Fast

❌ **Don't:**
```powershell
# Don't rush through phases
Test-PilotDeployment -PolicyId $id -PilotGroupId $pilot
Expand-PilotToProduction -PolicyId $id -ProductionGroupIds $all  # Too fast!
```

✅ **Do:**
```powershell
# Take time to monitor and validate
Test-PilotDeployment -PolicyId $id -PilotGroupId $pilot
# Wait 3-7 days, monitor, validate
# Then expand gradually
```

### 4. Ignoring Dependency Validation

❌ **Don't:**
```powershell
# Don't skip dependency checks
New-PolicyAssignment -PolicyId $appConfigPolicy
```

✅ **Do:**
```powershell
# Check dependencies first
$deps = Test-Dependencies -PolicyId $appConfigPolicy -PolicyType AppConfiguration
if ($deps.IsValid) {
    New-PolicyAssignment -PolicyId $appConfigPolicy
}
```

### 5. Poor Communication

❌ **Don't:**
- Make changes without notifying users
- Ignore user feedback
- Fail to provide support information

✅ **Do:**
- Send advance notifications
- Provide clear timelines
- Share support contact info
- Collect and address feedback

## Emergency Procedures

### If Issues Arise During Migration

**1. Stop the rollout:**
```powershell
# Don't expand to next phase
# Pause new assignments
```

**2. Assess the situation:**
```powershell
# Generate immediate report
$issueReport = Get-ComplianceReport -DeviceType Windows
$deviceIssues = Test-DeviceReadiness -DeviceType Windows
```

**3. Decide on action:**

**Minor issues (< 5% affected):**
- Continue monitoring
- Address individual cases
- Proceed with caution

**Major issues (> 10% affected):**
- Pause rollout
- Investigate root cause
- Consider rollback

**Critical issues (> 25% affected):**
- Immediate rollback
- Incident response
- Full investigation

**4. Execute rollback if needed:**
```powershell
Restore-PolicyConfiguration -BackupFile $backupPath
```

**5. Post-incident:**
- Document what happened
- Identify root cause
- Update procedures
- Plan remediation

## Checklist

### Pre-Migration Checklist

- [ ] Device inventory completed
- [ ] Device readiness validated
- [ ] User licensing verified
- [ ] Dependencies checked
- [ ] Pre-migration baseline report generated
- [ ] Rollback plan created
- [ ] Pilot group created
- [ ] Communication plan prepared
- [ ] Support team briefed
- [ ] Success criteria defined

### Migration Checklist

- [ ] Pilot deployment executed
- [ ] Pilot monitoring (3-7 days)
- [ ] Pilot issues resolved
- [ ] Early adopter deployment
- [ ] Early adopter monitoring (5-7 days)
- [ ] Production wave 1 deployment
- [ ] Production wave 1 monitoring
- [ ] Production wave 2 deployment
- [ ] Production wave 2 monitoring
- [ ] Final wave deployment

### Post-Migration Checklist

- [ ] Post-migration report generated
- [ ] Success rate calculated
- [ ] All issues documented
- [ ] Remaining issues assigned
- [ ] Compliance verified
- [ ] User feedback collected
- [ ] Lessons learned documented
- [ ] Reports archived
- [ ] Rollback plans retained
- [ ] Cleanup completed

## Summary

**Key Principles:**
1. **Validate before you migrate**
2. **Always have a rollback plan**
3. **Move in phases, not all at once**
4. **Monitor continuously**
5. **Communicate clearly**
6. **Document everything**
7. **Learn from each migration**

Following these best practices will significantly increase your migration success rate and reduce risk to your organization.

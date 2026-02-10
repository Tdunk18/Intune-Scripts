# Example: Complete Windows Device Migration

# This example demonstrates a complete migration workflow for Windows devices
# including validation, pilot testing, and rollback planning.

# Import the module
Import-Module .\IntuneScripts.psd1

# Step 1: Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
Connect-IntuneGraph

# Step 2: Define migration scope
$deviceType = "Windows"
$pilotGroupName = "Windows-Migration-Pilot"
$productionGroups = @("All-Windows-Devices")
$compliancePolicyId = "your-compliance-policy-id"

# Step 3: Pre-Migration Validation
Write-Host "`nRunning pre-migration validation..." -ForegroundColor Yellow

# Generate pre-migration baseline report
$preReportPath = Export-PreMigrationReport -DeviceType $deviceType -OutputPath ".\Reports"

# Check device readiness
$deviceReadiness = Test-DeviceReadiness -DeviceType $deviceType

# Display summary
$readyCount = ($deviceReadiness | Where-Object { $_.IsReady }).Count
$totalCount = $deviceReadiness.Count
Write-Host "Device Readiness: $readyCount/$totalCount devices ready" -ForegroundColor Cyan

# Check for blocking issues
$notReady = $deviceReadiness | Where-Object { -not $_.IsReady }
if ($notReady.Count -gt 0) {
    Write-Warning "The following devices are not ready for migration:"
    $notReady | ForEach-Object {
        Write-Warning "  - $($_.DeviceName): $($_.Issues -join ', ')"
    }
    
    $continue = Read-Host "Do you want to continue? (Y/N)"
    if ($continue -ne 'Y') {
        Write-Host "Migration cancelled by user" -ForegroundColor Red
        exit
    }
}

# Step 4: Create Rollback Plan
Write-Host "`nCreating rollback plan..." -ForegroundColor Yellow
$rollbackPlan = New-RollbackPlan `
    -PolicyIds @($compliancePolicyId) `
    -PolicyType Compliance `
    -OutputPath ".\Rollback" `
    -Description "Windows device migration rollback plan"

Write-Host "Rollback plan created: $($rollbackPlan.PlanFile)" -ForegroundColor Green
Write-Host "Backup files: $($rollbackPlan.BackupFiles.Count)" -ForegroundColor Green

# Step 5: Create and Configure Pilot Group
Write-Host "`nSetting up pilot group..." -ForegroundColor Yellow
$pilotGroup = New-PilotGroup `
    -GroupName $pilotGroupName `
    -Description "Pilot group for Windows device migration"

Write-Host "Pilot group created: $($pilotGroup.id)" -ForegroundColor Green

# Step 6: Deploy to Pilot
Write-Host "`nDeploying to pilot group..." -ForegroundColor Yellow
$pilotDeployment = Test-PilotDeployment `
    -PolicyId $compliancePolicyId `
    -PolicyType Compliance `
    -PilotGroupId $pilotGroup.id `
    -MonitoringDurationMinutes 60

Write-Host "`nPilot deployment initiated. Monitor for the next hour." -ForegroundColor Yellow
Write-Host "Run the following command to check compliance:" -ForegroundColor Cyan
Write-Host "  Get-ComplianceReport -PolicyId $compliancePolicyId" -ForegroundColor Cyan

# Wait for user confirmation before proceeding
$continue = Read-Host "`nAfter monitoring the pilot, do you want to expand to production? (Y/N)"
if ($continue -ne 'Y') {
    Write-Host "Production deployment cancelled. Pilot remains active." -ForegroundColor Yellow
    exit
}

# Step 7: Expand to Production
Write-Host "`nExpanding to production..." -ForegroundColor Yellow
Expand-PilotToProduction `
    -PolicyId $compliancePolicyId `
    -PolicyType Compliance `
    -ProductionGroupIds $productionGroups `
    -RemovePilotAssignment `
    -PilotGroupId $pilotGroup.id

Write-Host "Successfully expanded to production" -ForegroundColor Green

# Step 8: Post-Migration Validation
Write-Host "`nRunning post-migration validation..." -ForegroundColor Yellow

# Wait a bit for policies to apply
Write-Host "Waiting 5 minutes for policies to apply..." -ForegroundColor Cyan
Start-Sleep -Seconds 300

# Generate post-migration report
$postReportPath = Export-PostMigrationReport `
    -PreMigrationReportPath $preReportPath `
    -DeviceType $deviceType `
    -OutputPath ".\Reports"

Write-Host "Post-migration report generated: $postReportPath" -ForegroundColor Green

# Generate compliance report
$complianceReportPath = Get-ComplianceReport `
    -PolicyId $compliancePolicyId `
    -PolicyType Compliance `
    -DeviceType $deviceType `
    -OutputPath ".\Reports"

Write-Host "Compliance report generated: $complianceReportPath" -ForegroundColor Green

# Step 9: Summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Migration Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Reports Generated:" -ForegroundColor Cyan
Write-Host "  - Pre-Migration: $preReportPath" -ForegroundColor Cyan
Write-Host "  - Post-Migration: $postReportPath" -ForegroundColor Cyan
Write-Host "  - Compliance: $complianceReportPath" -ForegroundColor Cyan
Write-Host "`nRollback Information:" -ForegroundColor Cyan
Write-Host "  - Plan: $($rollbackPlan.PlanFile)" -ForegroundColor Cyan
Write-Host "  - Backups: $($rollbackPlan.BackupFiles -join ', ')" -ForegroundColor Cyan
Write-Host "`nTo rollback this migration, run:" -ForegroundColor Yellow
Write-Host "  Restore-PolicyConfiguration -BackupFile '$($rollbackPlan.BackupFiles[0])'" -ForegroundColor Yellow

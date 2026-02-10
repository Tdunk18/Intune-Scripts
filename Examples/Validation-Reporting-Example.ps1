# Example: Validation and Reporting Workflow

# This example demonstrates comprehensive validation and reporting
# for migration readiness and compliance.

# Import the module
Import-Module .\IntuneScripts.psd1

# Connect to Graph
Connect-IntuneGraph

# Configuration
$deviceType = "Windows"
$targetGroupId = "your-target-group-id"
$reportOutputPath = ".\Reports"

# Ensure output directory exists
if (-not (Test-Path $reportOutputPath)) {
    New-Item -ItemType Directory -Path $reportOutputPath | Out-Null
}

# Step 1: Device Readiness Check
Write-Host "Step 1: Checking device readiness..." -ForegroundColor Yellow
$deviceReadiness = Test-DeviceReadiness -DeviceType $deviceType

# Display summary
$readyDevices = $deviceReadiness | Where-Object { $_.IsReady }
$notReadyDevices = $deviceReadiness | Where-Object { -not $_.IsReady }

Write-Host "`nDevice Readiness Summary:" -ForegroundColor Cyan
Write-Host "  Total Devices: $($deviceReadiness.Count)" -ForegroundColor Cyan
Write-Host "  Ready: $($readyDevices.Count)" -ForegroundColor Green
Write-Host "  Not Ready: $($notReadyDevices.Count)" -ForegroundColor Red

if ($notReadyDevices.Count -gt 0) {
    Write-Host "`nDevices Not Ready:" -ForegroundColor Red
    $notReadyDevices | Select-Object -First 10 | ForEach-Object {
        Write-Host "  - $($_.DeviceName):" -ForegroundColor Red
        $_.Issues | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
    }
}

# Step 2: User Licensing Check
Write-Host "`nStep 2: Checking user licensing..." -ForegroundColor Yellow
$userLicensing = Test-UserLicensing -GroupId $targetGroupId

$licensedUsers = $userLicensing | Where-Object { $_.HasIntuneLicense }
$unlicensedUsers = $userLicensing | Where-Object { -not $_.HasIntuneLicense }

Write-Host "`nUser Licensing Summary:" -ForegroundColor Cyan
Write-Host "  Total Users: $($userLicensing.Count)" -ForegroundColor Cyan
Write-Host "  Licensed: $($licensedUsers.Count)" -ForegroundColor Green
Write-Host "  Unlicensed: $($unlicensedUsers.Count)" -ForegroundColor Red

if ($unlicensedUsers.Count -gt 0) {
    Write-Host "`nUnlicensed Users:" -ForegroundColor Red
    $unlicensedUsers | Select-Object -First 10 | ForEach-Object {
        Write-Host "  - $($_.UserPrincipalName)" -ForegroundColor Red
    }
}

# Step 3: Export Pre-Migration Report
Write-Host "`nStep 3: Generating pre-migration report..." -ForegroundColor Yellow
$preReportPath = Export-PreMigrationReport `
    -DeviceType $deviceType `
    -OutputPath $reportOutputPath

Write-Host "Pre-migration report saved: $preReportPath" -ForegroundColor Green

# Step 4: Generate Migration Report (multiple formats)
Write-Host "`nStep 4: Generating migration reports..." -ForegroundColor Yellow

# JSON format
$jsonReport = Get-MigrationReport `
    -DeviceType $deviceType `
    -OutputPath $reportOutputPath `
    -Format JSON

Write-Host "JSON report saved: $jsonReport" -ForegroundColor Green

# HTML format
$htmlReport = Get-MigrationReport `
    -DeviceType $deviceType `
    -OutputPath $reportOutputPath `
    -Format HTML

Write-Host "HTML report saved: $htmlReport" -ForegroundColor Green

# CSV format
$csvReport = Get-MigrationReport `
    -DeviceType $deviceType `
    -OutputPath $reportOutputPath `
    -Format CSV

Write-Host "CSV report saved: $csvReport" -ForegroundColor Green

# Step 5: Compliance Report
Write-Host "`nStep 5: Generating compliance report..." -ForegroundColor Yellow
$complianceReport = Get-ComplianceReport `
    -DeviceType $deviceType `
    -OutputPath $reportOutputPath

Write-Host "Compliance report saved: $complianceReport" -ForegroundColor Green

# Step 6: Summary Dashboard
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Validation and Reporting Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nReadiness:" -ForegroundColor Cyan
Write-Host "  ✓ Ready Devices: $($readyDevices.Count)" -ForegroundColor Green
Write-Host "  ✗ Not Ready: $($notReadyDevices.Count)" -ForegroundColor Red
$readinessPercent = [Math]::Round(($readyDevices.Count / $deviceReadiness.Count) * 100, 2)
Write-Host "  Readiness: $readinessPercent%" -ForegroundColor $(if ($readinessPercent -ge 90) { 'Green' } elseif ($readinessPercent -ge 70) { 'Yellow' } else { 'Red' })

Write-Host "`nLicensing:" -ForegroundColor Cyan
Write-Host "  ✓ Licensed Users: $($licensedUsers.Count)" -ForegroundColor Green
Write-Host "  ✗ Unlicensed: $($unlicensedUsers.Count)" -ForegroundColor Red

Write-Host "`nReports Generated:" -ForegroundColor Cyan
Write-Host "  - Pre-Migration: $preReportPath" -ForegroundColor Cyan
Write-Host "  - Migration (JSON): $jsonReport" -ForegroundColor Cyan
Write-Host "  - Migration (HTML): $htmlReport" -ForegroundColor Cyan
Write-Host "  - Migration (CSV): $csvReport" -ForegroundColor Cyan
Write-Host "  - Compliance: $complianceReport" -ForegroundColor Cyan

# Recommendations
Write-Host "`nRecommendations:" -ForegroundColor Yellow
if ($notReadyDevices.Count -gt 0) {
    Write-Host "  ⚠ Address device readiness issues before migration" -ForegroundColor Yellow
}
if ($unlicensedUsers.Count -gt 0) {
    Write-Host "  ⚠ Assign Intune licenses to unlicensed users" -ForegroundColor Yellow
}
if ($readinessPercent -ge 90 -and $unlicensedUsers.Count -eq 0) {
    Write-Host "  ✓ Ready to proceed with migration" -ForegroundColor Green
}

Write-Host "`nValidation complete!" -ForegroundColor Green

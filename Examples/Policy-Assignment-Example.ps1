# Example: Policy Assignment with Pilot Testing

# This example shows how to assign a policy to multiple groups
# with pilot testing before production rollout.

# Import the module
Import-Module .\IntuneScripts.psd1

# Connect to Graph
Connect-IntuneGraph

# Configuration
$policyId = "your-policy-id"
$policyType = "Configuration"  # or "Compliance", "AppProtection", "AppConfiguration"
$pilotGroupName = "Policy-Pilot-Group"
$productionGroups = @(
    "Production-Group-1",
    "Production-Group-2",
    "Production-Group-3"
)

# Step 1: Validate policy dependencies
Write-Host "Checking policy dependencies..." -ForegroundColor Yellow
$dependencies = Test-Dependencies -PolicyId $policyId -PolicyType $policyType

if (-not $dependencies.IsValid) {
    Write-Error "Policy has unmet dependencies:"
    $dependencies.Prerequisites | ForEach-Object {
        Write-Error "  - $_"
    }
    exit
}

# Step 2: Create backup
Write-Host "`nCreating backup..." -ForegroundColor Yellow
$backupPath = Backup-PolicyConfiguration `
    -PolicyId $policyId `
    -PolicyType $policyType `
    -BackupPath ".\Backups"

Write-Host "Backup created: $backupPath" -ForegroundColor Green

# Step 3: Create pilot group
Write-Host "`nCreating pilot group..." -ForegroundColor Yellow
$pilotGroup = New-PilotGroup `
    -GroupName $pilotGroupName `
    -Description "Pilot group for policy testing"

# Step 4: Deploy to pilot
Write-Host "`nDeploying to pilot group..." -ForegroundColor Yellow
$pilotTest = Test-PilotDeployment `
    -PolicyId $policyId `
    -PolicyType $policyType `
    -PilotGroupId $pilotGroup.id

Write-Host "Pilot deployment active. Monitor for issues." -ForegroundColor Yellow

# Pause for testing
$continue = Read-Host "`nPilot testing complete. Expand to production? (Y/N)"
if ($continue -ne 'Y') {
    Write-Host "Stopping. Pilot remains active." -ForegroundColor Yellow
    exit
}

# Step 5: Expand to production
Write-Host "`nExpanding to production groups..." -ForegroundColor Yellow

# Get production group IDs
$productionGroupIds = @()
foreach ($groupName in $productionGroups) {
    $group = Get-IntuneGraphData -Endpoint "groups" -Filter "displayName eq '$groupName'"
    if ($group) {
        $productionGroupIds += $group[0].id
        Write-Host "  Found group: $groupName" -ForegroundColor Cyan
    }
    else {
        Write-Warning "  Group not found: $groupName"
    }
}

# Expand to production
Expand-PilotToProduction `
    -PolicyId $policyId `
    -PolicyType $policyType `
    -ProductionGroupIds $productionGroupIds `
    -RemovePilotAssignment `
    -PilotGroupId $pilotGroup.id

Write-Host "`nPolicy successfully assigned to $($productionGroupIds.Count) production groups" -ForegroundColor Green

# Step 6: Verify assignments
Write-Host "`nVerifying assignments..." -ForegroundColor Yellow
$assignments = Get-PolicyAssignments -PolicyId $policyId -PolicyType $policyType

Write-Host "Total assignments: $($assignments.Count)" -ForegroundColor Cyan
$assignments | ForEach-Object {
    Write-Host "  - Group ID: $($_.target.groupId)" -ForegroundColor Cyan
}

Write-Host "`nPolicy assignment complete!" -ForegroundColor Green
Write-Host "Backup file: $backupPath" -ForegroundColor Cyan

<#
.SYNOPSIS
    Test script for the SpywareDetection module

.DESCRIPTION
    This script validates the functionality of the SpywareDetection module
    by running various tests and checks.

.NOTES
    Version: 1.0.0
    Author: Intune Security Team
#>

#Requires -Version 5.1

param(
    [Parameter(Mandatory = $false)]
    [switch]$DetailedOutput
)

if ($DetailedOutput) {
    $VerbosePreference = 'Continue'
}

Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SpywareDetection Module - Test Suite              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0
$testsTotal = 0

function Test-ModuleFunction {
    param(
        [string]$TestName,
        [scriptblock]$TestScript
    )
    
    $script:testsTotal++
    Write-Host "[$script:testsTotal] Testing: $TestName..." -NoNewline
    
    try {
        $result = & $TestScript
        if ($result) {
            Write-Host " ✓ PASSED" -ForegroundColor Green
            $script:testsPassed++
            return $true
        }
        else {
            Write-Host " ✗ FAILED" -ForegroundColor Red
            $script:testsFailed++
            return $false
        }
    }
    catch {
        Write-Host " ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

# Import the module
Write-Host "Importing SpywareDetection module..." -ForegroundColor Yellow
$modulePath = Join-Path $PSScriptRoot "..\Modules\SpywareDetection.psm1"

if (-not (Test-Path $modulePath)) {
    Write-Host "ERROR: Module not found at $modulePath" -ForegroundColor Red
    exit 1
}

Import-Module $modulePath -Force
Write-Host "Module imported successfully!`n" -ForegroundColor Green

# Test 1: Module functions are available
Test-ModuleFunction "Get-SuspiciousProcess function exists" {
    Get-Command -Name Get-SuspiciousProcess -ErrorAction SilentlyContinue
}

Test-ModuleFunction "Get-SuspiciousStartupEntry function exists" {
    Get-Command -Name Get-SuspiciousStartupEntry -ErrorAction SilentlyContinue
}

Test-ModuleFunction "Get-SuspiciousNetworkConnection function exists" {
    Get-Command -Name Get-SuspiciousNetworkConnection -ErrorAction SilentlyContinue
}

Test-ModuleFunction "Get-SuspiciousFile function exists" {
    Get-Command -Name Get-SuspiciousFile -ErrorAction SilentlyContinue
}

Test-ModuleFunction "Start-SpywareScan function exists" {
    Get-Command -Name Start-SpywareScan -ErrorAction SilentlyContinue
}

# Test 2: Basic functionality tests (non-intrusive)
Test-ModuleFunction "Get-SuspiciousProcess returns data structure" {
    $result = Get-SuspiciousProcess -ErrorAction SilentlyContinue
    $result -is [System.Array] -or $result -eq $null
}

Test-ModuleFunction "Get-SuspiciousStartupEntry returns data structure" {
    $result = Get-SuspiciousStartupEntry -ErrorAction SilentlyContinue
    $result -is [System.Array] -or $result -eq $null
}

Test-ModuleFunction "Get-SuspiciousNetworkConnection returns data structure" {
    $result = Get-SuspiciousNetworkConnection -ErrorAction SilentlyContinue
    $result -is [System.Array] -or $result -eq $null
}

# Test 3: Directory structure
Test-ModuleFunction "Logs directory can be created" {
    $logPath = Join-Path $PSScriptRoot "..\Logs"
    if (-not (Test-Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    Test-Path $logPath
}

Test-ModuleFunction "Reports directory can be created" {
    $reportPath = Join-Path $PSScriptRoot "..\Reports"
    if (-not (Test-Path $reportPath)) {
        New-Item -ItemType Directory -Path $reportPath -Force | Out-Null
    }
    Test-Path $reportPath
}

Test-ModuleFunction "Config directory exists" {
    $configPath = Join-Path $PSScriptRoot "..\Config"
    Test-Path $configPath
}

Test-ModuleFunction "SecurityConfig.yaml exists" {
    $configFile = Join-Path $PSScriptRoot "..\Config\SecurityConfig.yaml"
    Test-Path $configFile
}

# Test 4: Logging functionality
Test-ModuleFunction "Write-SecurityLog creates log file" {
    Write-SecurityLog -Message "Test log entry" -Level Info
    $logFile = Join-Path $PSScriptRoot "..\Logs\SpywareDetection_$(Get-Date -Format 'yyyyMMdd').log"
    Test-Path $logFile
}

# Test 5: Remediation functions exist
Test-ModuleFunction "Stop-SuspiciousProcess function exists" {
    Get-Command -Name Stop-SuspiciousProcess -ErrorAction SilentlyContinue
}

Test-ModuleFunction "Remove-SuspiciousStartupEntry function exists" {
    Get-Command -Name Remove-SuspiciousStartupEntry -ErrorAction SilentlyContinue
}

Test-ModuleFunction "Move-SuspiciousFileToQuarantine function exists" {
    Get-Command -Name Move-SuspiciousFileToQuarantine -ErrorAction SilentlyContinue
}

# Display test summary
Write-Host "`n╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Test Summary                                       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Tests: $testsTotal" -ForegroundColor White
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✓ All tests passed!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "✗ Some tests failed!" -ForegroundColor Red
    exit 1
}

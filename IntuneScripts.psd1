@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'IntuneScripts.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789012'

    # Author of this module
    Author = 'Intune Scripts Team'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2026. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module for managing Intune device migrations, policy assignments, and Graph API integration'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    # Note: These are required for production use. Install with:
    # Install-Module -Name Microsoft.Graph.Authentication -MinimumVersion 2.0.0
    # Install-Module -Name Microsoft.Graph.DeviceManagement -MinimumVersion 2.0.0
    # RequiredModules = @(
    #     @{ModuleName = 'Microsoft.Graph.Authentication'; ModuleVersion = '2.0.0'},
    #     @{ModuleName = 'Microsoft.Graph.DeviceManagement'; ModuleVersion = '2.0.0'}
    # )

    # Functions to export from this module
    FunctionsToExport = @(
        # Device Management
        'Get-IntuneDevicesByScope',
        'Set-DeviceScope',
        
        # Policy Management
        'New-PolicyAssignment',
        'Set-PolicyAssignment',
        'Remove-PolicyAssignment',
        'Get-PolicyAssignments',
        
        # Pilot Testing
        'New-PilotGroup',
        'Test-PilotDeployment',
        'Expand-PilotToProduction',
        
        # Rollback
        'Backup-PolicyConfiguration',
        'Restore-PolicyConfiguration',
        'New-RollbackPlan',
        
        # Validation
        'Test-DeviceReadiness',
        'Test-UserLicensing',
        'Test-Dependencies',
        
        # Reporting
        'Get-MigrationReport',
        'Get-ComplianceReport',
        'Export-PreMigrationReport',
        'Export-PostMigrationReport',
        
        # Graph API
        'Connect-IntuneGraph',
        'Invoke-IntuneGraphRequest',
        'Get-IntuneGraphData'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            Tags = @('Intune', 'DeviceManagement', 'Migration', 'GraphAPI', 'Azure')
            LicenseUri = 'https://github.com/Tdunk18/Intune-Scripts/blob/main/LICENSE'
            ProjectUri = 'https://github.com/Tdunk18/Intune-Scripts'
        }
    }
}

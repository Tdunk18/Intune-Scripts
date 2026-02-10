# Changelog

All notable changes to the IntuneScripts PowerShell module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-10

### Added

#### Device and Policy Management
- **Device Scope Selection**: Functions to filter and manage devices by type (iOS, Android, macOS, Windows)
  - `Get-IntuneDevicesByScope` - Retrieve devices filtered by device type
  - `Set-DeviceScope` - Configure device scope for operations
  
- **Policy Assignment**: Comprehensive policy management functions
  - `New-PolicyAssignment` - Create new policy assignments
  - `Get-PolicyAssignments` - Retrieve existing policy assignments
  - `Set-PolicyAssignment` - Update policy assignments
  - `Remove-PolicyAssignment` - Delete policy assignments
  - Support for multiple policy types: Compliance, Configuration, AppProtection, AppConfiguration

- **Pilot-Friendly Implementation**: Test policies on pilot groups before production
  - `New-PilotGroup` - Create Azure AD groups for pilot testing
  - `Test-PilotDeployment` - Deploy and monitor pilot deployments
  - `Expand-PilotToProduction` - Expand successful pilots to production groups

- **Rollback Plans**: Automated backup and rollback procedures
  - `Backup-PolicyConfiguration` - Backup policy settings and assignments
  - `Restore-PolicyConfiguration` - Restore from backup
  - `New-RollbackPlan` - Generate documented rollback procedures with markdown documentation

#### Validation and Reporting
- **Pre-Migration Validation**:
  - `Test-DeviceReadiness` - Validate device readiness (co-management, hybrid AD-join, OS compatibility)
  - `Test-UserLicensing` - Check user Intune license compliance
  - `Test-Dependencies` - Verify policy and app dependencies

- **Migration Reporting**:
  - `Export-PreMigrationReport` - Generate baseline reports before migration
  - `Export-PostMigrationReport` - Generate comparison reports after migration
  - `Get-MigrationReport` - Comprehensive migration reports (JSON, CSV, HTML formats)
  - `Get-ComplianceReport` - Compliance status reporting

#### Graph API Integration
- **Microsoft Graph Support**: Full integration with Microsoft Graph API
  - `Connect-IntuneGraph` - Connect to Microsoft Graph with appropriate scopes
  - `Invoke-IntuneGraphRequest` - Execute Graph API requests with error handling
  - `Get-IntuneGraphData` - Retrieve data with OData support

- **OData Querying**: Efficient data filtering
  - Support for `$filter` parameter for server-side filtering
  - Support for `$select` parameter to limit returned fields
  - Support for `$expand` parameter to include related data
  - Automatic paging for large result sets

- **Rate Limiting and Retry Logic**:
  - Automatic retry on HTTP 429 (Too Many Requests)
  - Automatic retry on HTTP 503 (Service Unavailable)
  - Exponential backoff strategy
  - Respect for `Retry-After` headers
  - Configurable retry limits (default: 5 attempts)

#### Documentation
- Comprehensive README with feature overview and quick start guide
- **GraphAPI-Guide.md**: Detailed Graph API integration documentation
  - Connection examples
  - OData query examples
  - Error handling patterns
  - Best practices
  
- **Migration-Best-Practices.md**: Enterprise migration guidance
  - Pre-migration planning
  - Phased rollout strategies
  - Risk mitigation
  - Monitoring and validation
  - Post-migration procedures
  - Emergency procedures
  
- **Getting-Started.md**: Step-by-step tutorial for new users
  - Prerequisites and installation
  - First migration walkthrough
  - Common tasks
  - Troubleshooting guide

#### Examples
- **Complete-Migration-Example.ps1**: End-to-end migration workflow
- **Policy-Assignment-Example.ps1**: Policy assignment with pilot testing
- **Device-Scope-Example.ps1**: Device filtering and OData queries
- **Validation-Reporting-Example.ps1**: Validation and reporting workflow

#### Module Structure
- PowerShell module manifest (IntuneScripts.psd1)
- Module loader (IntuneScripts.psm1)
- 22 public functions
- 2 private helper functions
- Proper function categorization (Public/Private)

### Features by Requirement

#### Requirement 3: Device and Policy Management ✓
- ✓ Device Scope: Filter by iOS, Android, macOS, Windows
- ✓ Policy Assignment: Handle compliance, configuration, app protection policies
- ✓ Pilot Implementation: Test on pilot groups before production
- ✓ Rollback Plans: Backup, restore, and documented procedures

#### Requirement 4: Validation and Reporting ✓
- ✓ Pre-migration Checks: Device readiness and user licensing validation
- ✓ Migration Reporting: Pre/post migration reports with comparison
- ✓ Compliance Analytics: Detailed compliance state tracking
- ✓ Dependency Validation: Check app and policy prerequisites

#### Requirement 5: Graph API Integration ✓
- ✓ Microsoft Graph Support: Full integration with Microsoft.Graph modules
- ✓ OData Querying: $filter, $expand, $select support
- ✓ Rate Limiting: Exponential backoff and retry logic

### Technical Details
- **PowerShell Version**: 5.1 minimum
- **Dependencies**: 
  - Microsoft.Graph.Authentication v2.0.0+
  - Microsoft.Graph.DeviceManagement v2.0.0+
- **Functions**: 24 total (22 public, 2 private)
- **Documentation**: 4 comprehensive guides + 4 example scripts
- **Lines of Code**: ~3,750+ lines

### Breaking Changes
None - Initial release

### Known Issues
None

### Notes
- All functions include comprehensive help documentation with examples
- All functions follow PowerShell best practices with proper parameter validation
- ShouldProcess support for destructive operations
- Consistent error handling across all functions
- Verbose logging support for troubleshooting

[1.0.0]: https://github.com/Tdunk18/Intune-Scripts/releases/tag/v1.0.0

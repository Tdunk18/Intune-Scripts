# On-Premises Scripts

This folder contains scripts for managing on-premises infrastructure and facilitating hybrid scenarios.

## Subfolders

### Active-Directory
Scripts for Active Directory Domain Services management.
- User and computer object management
- Group management
- OU structure organization
- AD attribute updates for cloud sync

### Group-Policy
Scripts for Group Policy operations during migration.
- GPO inventory and documentation
- Policy migration planning
- GPO to Intune policy mapping

### SCCM
Scripts for Microsoft Endpoint Configuration Manager (formerly SCCM).
- Co-management configuration
- Client health checks
- Migration from SCCM to Intune
- Inventory and reporting

### Legacy-Management
Scripts for legacy management systems and tools.
- Third-party tool integration
- Legacy cleanup operations
- Deprecation planning

## Usage

These scripts support organizations with on-premises infrastructure or in hybrid scenarios. Use these during migration planning and execution phases.

## Prerequisites

- On-premises infrastructure access
- Active Directory domain
- Appropriate administrative permissions
- PowerShell modules:
  - ActiveDirectory
  - ConfigurationManager (for SCCM)

# Intune-Scripts

A comprehensive collection of scripts and tools to help organizations migrate to and manage Microsoft Intune for cloud-based device management.

## Overview

This repository provides a structured approach to migrating from on-premises or hybrid device management to Microsoft Intune. The scripts are organized to support organizations at every stage of their cloud management journey.

## Folder Structure

### 📁 Cloud
Scripts for cloud-based device and identity management using Microsoft Intune and Azure services.
- **Intune-Management**: Device enrollment, app deployment, configuration profiles
- **Entra-ID**: User/group management, device registration, hybrid join
- **Conditional-Access**: Policy creation and management
- **Compliance-Policies**: Compliance policy deployment and reporting

### 📁 On-Premises
Scripts for managing on-premises infrastructure and hybrid scenarios.
- **Active-Directory**: AD object management and cloud sync preparation
- **Group-Policy**: GPO inventory, migration planning, policy mapping
- **SCCM**: Co-management, client health, migration from SCCM
- **Legacy-Management**: Third-party tools, legacy cleanup

### 📁 Migration
Scripts to facilitate the migration journey from on-premises to cloud.
- **Pre-Migration**: Assessment, readiness checks, inventory, planning
- **During-Migration**: Device transition, co-management, phased rollout
- **Post-Migration**: Cleanup, decommissioning, final reporting
- **Validation**: Enrollment verification, policy checks, compliance validation

### 📁 GraphAPI
Microsoft Graph API scripts for programmatic management.
- **Device-Management**: Device operations, compliance queries, remote actions
- **User-Management**: User provisioning, licenses, authentication
- **App-Management**: Application deployment and protection policies
- **Policy-Management**: Configuration, compliance, and conditional access policies
- **Reporting**: Compliance reports, analytics, audit logs

### 📁 Maintenance
Scripts for ongoing maintenance and optimization.
- **Cleanup**: Stale device removal, orphaned objects, license optimization
- **Monitoring**: Health checks, compliance monitoring, alert generation
- **Audit**: Change tracking, access reviews, security baselines
- **Optimization**: Policy consolidation, performance tuning, cost optimization

### 📁 Reporting
Scripts for comprehensive reporting across Intune and Azure environments.
- **Compliance-Reports**: Device and policy compliance tracking
- **Device-Reports**: Complete device inventory and health status
- **User-Reports**: User device assignments, licenses, adoption
- **Application-Reports**: App deployment status and usage analytics
- **Security-Reports**: Security posture, threats, encryption status
- **Custom-Reports**: Executive dashboards and custom KPIs

## Getting Started

1. **Assess Your Environment**: Start with scripts in `Migration/Pre-Migration`
2. **Plan Your Migration**: Review `Migration/README.md` for migration phases
3. **Setup Authentication**: Configure Graph API access for cloud scripts
4. **Execute Migration**: Follow phased approach using `Migration/During-Migration`
5. **Validate**: Use scripts in `Migration/Validation` to verify success
6. **Maintain**: Implement regular maintenance using `Maintenance` scripts

## Prerequisites

### For Cloud Scripts
- Azure AD/Entra ID tenant
- Microsoft Intune licenses
- Graph API permissions configured
- PowerShell modules: Microsoft.Graph, Az

### For On-Premises Scripts
- Active Directory access
- Appropriate administrative permissions
- PowerShell modules: ActiveDirectory, ConfigurationManager

### For Migration Scripts
- Access to both on-premises and cloud environments
- Migration plan and pilot group defined
- Rollback procedures documented

## Contributing

Contributions are welcome! Please ensure scripts:
- Are well-documented with comments
- Include usage examples
- Follow PowerShell best practices
- Are placed in the appropriate folder

## Support

For issues or questions about specific scripts, please open an issue in this repository.

## License

This project is licensed under the terms specified in the LICENSE file. 

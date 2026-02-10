# Device Reports

This folder contains scripts for comprehensive device inventory and status reporting.

## Purpose

Scripts in this folder help with:
- Complete device inventory tracking
- Device health and status monitoring
- Hardware and software inventory
- Device lifecycle management
- Enrollment and configuration status

## Example Scripts

Place scripts here such as:
- `Get-DeviceInventoryReport.ps1` - Complete device inventory
- `Get-DeviceHealthReport.ps1` - Device health status across fleet
- `Get-OSDistributionReport.ps1` - Operating system versions
- `Get-HardwareInventoryReport.ps1` - Hardware specifications
- `Get-DeviceLifecycleReport.ps1` - Device age and refresh tracking
- `Get-EnrollmentStatusReport.ps1` - Enrollment success/failure rates
- `Get-StaleDevicesReport.ps1` - Inactive or stale devices
- `Get-DeviceByLocationReport.ps1` - Device distribution by location

## Report Categories

### Inventory Reports
- Total device count
- Device types (laptop, desktop, tablet, mobile)
- Manufacturer and model breakdown
- Serial numbers and asset tags
- Memory, storage, and CPU specs

### Health Reports
- Device sync status
- Last check-in time
- Battery health (for mobile devices)
- Disk space utilization
- Pending updates or actions

### Lifecycle Reports
- Device age and warranty status
- Devices due for refresh
- End-of-life tracking
- Deprecation planning

### Configuration Reports
- Configuration profile assignment
- Application deployment status
- Feature update readiness
- Security configuration status

## Key Metrics

Important device metrics to track:
- Total managed devices
- Active vs. inactive devices
- Average device age
- Enrollment success rate
- Device health score
- Sync failure rate

## Data Points

Common data points to include:
- Device name
- Serial number
- User assigned
- Last sync time
- OS version
- Compliance status
- Management state
- Enrollment date

## Export Formats

Recommended formats for device reports:
- **CSV**: For inventory management systems
- **Excel**: For analysis with charts and pivots
- **JSON**: For integration with CMDB
- **HTML**: For web dashboards

## Best Practices

1. Include timestamp on all reports
2. Filter out test or decommissioned devices
3. Highlight devices requiring attention
4. Use color coding for status indicators
5. Include summary statistics at top

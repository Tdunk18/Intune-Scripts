function New-PilotGroup {
    <#
    .SYNOPSIS
        Creates a new Azure AD group for pilot testing.
    
    .DESCRIPTION
        Creates an Azure AD security group that can be used for pilot deployments
        of policies and configurations.
    
    .PARAMETER GroupName
        The name for the pilot group.
    
    .PARAMETER Description
        Description for the pilot group.
    
    .PARAMETER MailNickname
        Mail nickname for the group (defaults to sanitized group name).
    
    .EXAMPLE
        New-PilotGroup -GroupName "Intune-Pilot-iOS" -Description "Pilot group for iOS device testing"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        
        [Parameter(Mandatory = $false)]
        [string]$Description = "Pilot group for Intune policy testing",
        
        [Parameter(Mandatory = $false)]
        [string]$MailNickname
    )
    
    try {
        # Generate mail nickname if not provided
        if (-not $MailNickname) {
            $MailNickname = $GroupName -replace '[^a-zA-Z0-9]', ''
        }
        
        $groupBody = @{
            displayName = $GroupName
            description = $Description
            mailEnabled = $false
            mailNickname = $MailNickname
            securityEnabled = $true
        }
        
        if ($PSCmdlet.ShouldProcess($GroupName, "Create pilot group")) {
            $group = Invoke-IntuneGraphRequest -Uri "https://graph.microsoft.com/v1.0/groups" -Method POST -Body $groupBody
            
            Write-Host "Successfully created pilot group" -ForegroundColor Green
            Write-Host "  Name: $GroupName" -ForegroundColor Cyan
            Write-Host "  ID: $($group.id)" -ForegroundColor Cyan
            Write-Host "  Description: $Description" -ForegroundColor Cyan
            
            return $group
        }
    }
    catch {
        Write-Error "Failed to create pilot group: $_"
        throw
    }
}

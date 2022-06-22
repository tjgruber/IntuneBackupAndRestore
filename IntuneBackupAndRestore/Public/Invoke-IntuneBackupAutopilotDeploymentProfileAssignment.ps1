﻿function Invoke-IntuneBackupAutopilotDeploymentProfileAssignment {
    <#
    .SYNOPSIS
    Backup Intune Autopilot Deployment Profile Assignments
    
    .DESCRIPTION
    Backup Intune Autopilot Deployment Profile Assignments as JSON files per Deployment Profile to the specified Path.
    
    .PARAMETER Path
    Path to store backup files
    
    .EXAMPLE
    Invoke-IntuneBackupAutopilotDeploymentProfileAssignment -Path "C:\temp"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Set the Microsoft Graph API endpoint
    if (-not ((Get-MSGraphEnvironment).SchemaVersion -eq $apiVersion)) {
        Update-MSGraphEnvironment -SchemaVersion $apiVersion -Quiet
        Connect-MSGraph -ForceNonInteractive -Quiet
    }

    # Create folder if not exists
    if (-not (Test-Path "$Path\Autopilot Deployment Profiles\Assignments")) {
        $null = New-Item -Path "$Path\Autopilot Deployment Profiles\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $winAutopilotDeploymentProfiles = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeploymentProfiles" | Get-MSGraphAllPages

    foreach ($winAutopilotDeploymentProfile in $winAutopilotDeploymentProfiles) {
        $assignments = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeploymentProfiles/$($winAutopilotDeploymentProfile.id)/assignments" | Get-MSGraphAllPages
        
        if ($assignments) {
            $fileName = ($winAutopilotDeploymentProfile.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $assignments | ConvertTo-Json | Out-File -LiteralPath "$path\Autopilot Deployment Profiles\Assignments\$fileName.json"

            [PSCustomObject]@{
                "Action" = "Backup"
                "Type"   = "Autopilot Deployment Profile Assignments"
                "Name"   = $winAutopilotDeploymentProfile.displayName
                "Path"   = "Autopilot Deployment Profiles\Assignments\$fileName.json"
            }
        }
    }
}
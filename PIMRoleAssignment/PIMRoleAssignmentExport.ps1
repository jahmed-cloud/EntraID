# PIM Role Assignment Export Script with Debugging
# Author: Junaid Ahmed
# Description: Export PIM role assignments (active and eligible) with summary and full details.

# Requires: Microsoft.Graph PowerShell SDK v2+
# Permissions: RoleManagement.Read.Directory, Directory.Read.All

# ------------------------- Setup & Debugging -------------------------
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Green
try {
    Import-Module Microsoft.Graph -MinimumVersion 2.0.0 -ErrorAction Stop
    Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All"
    Select-MgProfile -Name "beta"
} catch {
    Write-Error "Failed to connect to Microsoft Graph. $_"
    exit
}

# ------------------------- Initialize Variables -------------------------
$allAssignments = @()
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$fullReport = "PIM_Assignments_Details_$timestamp.csv"
$summaryReport = "PIM_Assignments_Summary_$timestamp.csv"

# ------------------------- Get Role Definitions -------------------------
try {
    $directoryRoles = Get-MgRoleManagementDirectoryRoleDefinition -All
    Write-Host "Fetched $($directoryRoles.Count) roles." -ForegroundColor Cyan
} catch {
    Write-Error "Error fetching role definitions: $_"
    exit
}

# ------------------------- Process Each Role -------------------------
foreach ($role in $directoryRoles) {
    Write-Verbose "Processing Role: $($role.DisplayName)"

    # Eligible Assignments
    try {
        $eligibleAssignments = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance -Filter "roleDefinitionId eq '$($role.Id)'" -All
        foreach ($ea in $eligibleAssignments) {
            $userOrGroup = try { Get-MgDirectoryObject -DirectoryObjectId $ea.PrincipalId } catch { $null }
            $allAssignments += [PSCustomObject]@{
                RoleName          = $role.DisplayName
                AssignmentType    = "Eligible"
                AssignedTo        = $userOrGroup.AdditionalProperties.displayName
                PrincipalId       = $ea.PrincipalId
                ActivationStatus  = "Not Activated"
                AssignmentState   = $ea.AssignmentState
                AssignmentExpires = $ea.EndDateTime
                Source            = "PIM"
            }
        }
    } catch {
        Write-Warning "No eligible assignments found for $($role.DisplayName)"
    }

    # Active Assignments
    try {
        $activeAssignments = Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance -Filter "roleDefinitionId eq '$($role.Id)'" -All
        foreach ($aa in $activeAssignments) {
            $userOrGroup = try { Get-MgDirectoryObject -DirectoryObjectId $aa.PrincipalId } catch { $null }
            $allAssignments += [PSCustomObject]@{
                RoleName          = $role.DisplayName
                AssignmentType    = "Active"
                AssignedTo        = $userOrGroup.AdditionalProperties.displayName
                PrincipalId       = $aa.PrincipalId
                ActivationStatus  = "Activated"
                AssignmentState   = $aa.AssignmentState
                AssignmentExpires = $aa.EndDateTime
                Source            = "PIM"
            }
        }
    } catch {
        Write-Warning "No active assignments found for $($role.DisplayName)"
    }
}

# ------------------------- Summary -------------------------
$summary = $allAssignments | Group-Object RoleName,AssignmentType | Select-Object `
    @{Name='RoleName';Expression={$_.Group[0].RoleName}},
    @{Name='AssignmentType';Expression={$_.Group[0].AssignmentType}},
    @{Name='AssignmentCount';Expression={$_.Count}}

# ------------------------- Export -------------------------
try {
    $allAssignments | Export-Csv -Path $fullReport -NoTypeInformation -Encoding UTF8
    $summary | Export-Csv -Path $summaryReport -NoTypeInformation -Encoding UTF8
    Write-Host "Export complete. Files:" -ForegroundColor Green
    Write-Host "- $fullReport"
    Write-Host "- $summaryReport"
} catch {
    Write-Error "Export failed: $_"
}

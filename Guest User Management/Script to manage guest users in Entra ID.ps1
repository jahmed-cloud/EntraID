<#
.SYNOPSIS
    Script to manage guest users in Entra ID.

.DESCRIPTION
    - Finds guest users who have not accepted their invite.
    - Finds guest users who have not signed in the last 30 days.
    - Exports data to CSV at C:\Entra ID\Guest Users.
    - Provides options to delete users from CSV.
    - Logs actions for better troubleshooting.

.AUTHOR
    Junaid Ahmed
    GitHub: https://github.com/jahmed-cloud
#>

# Ensure Microsoft Graph module is installed and imported
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Applications)) {
    Install-Module Microsoft.Graph.Applications -Force -AllowClobber
}

Import-Module Microsoft.Graph.Applications

# Create log file location
$LogPath = "C:\Entra ID\Guest Users\script_log.txt"
$ExportPath = "C:\Entra ID\Guest Users"

# Ensure the directory exists
if (!(Test-Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
}

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$Timestamp - $Message"
}

# Function to export guest users who have not accepted the invite
function Export-PendingGuests {
    Write-Log "Fetching guest users who have not accepted the invite..."
    $PendingGuests = Get-MgUser -Filter "UserType eq 'Guest' and ExternalUserState eq 'PendingAcceptance'" -All
    if ($PendingGuests) {
        $PendingGuests | Select-Object DisplayName, UserPrincipalName, CreatedDateTime |
        Export-Csv -Path "$ExportPath\PendingGuests.csv" -NoTypeInformation
        Write-Log "Exported pending guests to PendingGuests.csv"
    } else {
        Write-Log "No pending guest users found."
    }
}

# Function to export guest users who have not signed in the last 30 days
function Export-InactiveGuests {
    Write-Log "Fetching guest users who have not signed in the last 30 days..."
    $LastSignInThreshold = (Get-Date).AddDays(-30)
    $InactiveGuests = Get-MgUser -Filter "UserType eq 'Guest'" -All | Where-Object {
        $_.SignInActivity.LastSignInDateTime -eq $null -or $_.SignInActivity.LastSignInDateTime -lt $LastSignInThreshold
    }

    if ($InactiveGuests) {
        $InactiveGuests | Select-Object DisplayName, UserPrincipalName, SignInActivity |
        Export-Csv -Path "$ExportPath\InactiveGuests.csv" -NoTypeInformation
        Write-Log "Exported inactive guests to InactiveGuests.csv"
    } else {
        Write-Log "No inactive guest users found."
    }
}

# Function to delete users from CSV file
function Delete-UsersFromCSV {
    param (
        [string]$FilePath
    )
    if (!(Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath"
        Write-Log "File not found: $FilePath"
        return
    }

    $UsersToDelete = Import-Csv -Path $FilePath
    foreach ($User in $UsersToDelete) {
        try {
            Write-Log "Deleting guest user: $($User.UserPrincipalName)"
            Remove-MgUser -UserId $User.UserPrincipalName -Confirm:$false
            Write-Log "Deleted guest user: $($User.UserPrincipalName)"
        } catch {
            Write-Log "Error deleting guest user $($User.UserPrincipalName): $($_.Exception.Message)"
        }
    }
}

# Function to display menu
function Show-Menu {
    Clear-Host
    Write-Host "==========================================="
    Write-Host "      Entra ID - Guest User Management     "
    Write-Host "==========================================="
    Write-Host "1. Export guest users who have not accepted the invite"
    Write-Host "2. Export guest users who have not signed in the last 30 days"
    Write-Host "3. Delete guest users from PendingGuests.csv"
    Write-Host "4. Delete guest users from InactiveGuests.csv"
    Write-Host "5. Exit"
}

# Run the menu
while ($true) {
    Show-Menu
    $Selection = Read-Host "Enter your choice"
    
    switch ($Selection) {
        "1" { Export-PendingGuests }
        "2" { Export-InactiveGuests }
        "3" { Delete-UsersFromCSV -FilePath "$ExportPath\PendingGuests.csv" }
        "4" { Delete-UsersFromCSV -FilePath "$ExportPath\InactiveGuests.csv" }
        "5" { Write-Host "Exiting script..."; exit }
        default { Write-Host "Invalid choice. Please select a valid option." }
    }
}

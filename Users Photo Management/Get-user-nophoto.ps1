$TenantId = "f91b2525-a478-214030a4819f"
$ClientId = "dc784ec7-a9f2-4e50"
$ClientSecret = "RC58Q~aK4"
$LogPath = "C:\Images\logs.log"
$CsvPath = "C:\Images\NoPhotoUsers.csv"

$Body = @{
    'tenant' = $TenantId
    'client_id' = $ClientId
    'scope' = 'https://graph.microsoft.com/.default'
    'client_secret' = $ClientSecret
    'grant_type' = 'client_credentials'
}

$Params = @{
    'Uri' = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    'Method' = 'Post'
    'Body' = $Body
    'ContentType' = 'application/x-www-form-urlencoded'
}

$NoPhotoUsers = @()

try {
    $AuthResponse = Invoke-RestMethod @Params
    $Headers = @{
        'Authorization' = "Bearer $($AuthResponse.access_token)"
    }

    $UsersUri = "https://graph.microsoft.com/v1.0/users"
    do {
        $Users = Invoke-RestMethod -Uri $UsersUri -Headers $Headers -Method Get
        foreach ($User in $Users.value) {
            try {
                $PhotoResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$($User.id)/photo/\$value" -Headers $Headers -Method Get -ErrorAction Stop
                Write-Host "Photo exists for user: $($User.displayName)"
            } catch {
                Write-Host "No photo for user: $($User.displayName)"
                Add-Content -Path $LogPath -Value "[$(Get-Date)] No photo for user: $($User.displayName) ($($User.mail))`n"
                $NoPhotoUsers += [PSCustomObject]@{
                    DisplayName = $User.displayName
                    Email = $User.mail
                }
            }
        }
        $UsersUri = $Users.'@odata.nextLink'
    } while ($UsersUri -ne $null)

    # Save the list of users without photos to a CSV file
    $NoPhotoUsers | Export-Csv -Path $CsvPath -NoTypeInformation

} catch {
    Write-Host "Authentication failed: $_"
    Add-Content -Path $LogPath -Value "[$(Get-Date)] Authentication failed: $_`n"
}

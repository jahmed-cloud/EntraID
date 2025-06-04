$TenantId = "f91b2525-a478"
$ClientId = "dc784ec7-a9f2"
$ClientSecret = "RC58Q~o2IQyNIlzs~aK4"
$CsvPath = "C:\Images\userpic.csv"
$LogPath = "C:\Images\logs.log"

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

try {
    $AuthResponse = Invoke-RestMethod @Params
    $Headers = @{
        'Authorization' = "Bearer $($AuthResponse.access_token)"
    }

    Import-Csv -Path $CsvPath | ForEach-Object {
        try {
            Invoke-RestMethod -Method Put -Uri "https://graph.microsoft.com/v1.0/users/$($_.mail)/photo/`$value" -Headers $Headers -ContentType "image/jpeg" -InFile $_.path
            Write-Host "Successfully updated photo for $($_.mail)"
            Add-Content -Path $LogPath -Value "[$(Get-Date)] Successfully updated photo for $($_.mail)`n"
        } catch {
            Write-Host "Failed to update photo for $($_.mail): $_"
            Add-Content -Path $LogPath -Value "[$(Get-Date)] Failed to update photo for $($_.mail): $_`n"
        }
    }
} catch {
    Write-Host "Authentication failed: $_"
    Add-Content -Path $LogPath -Value "[$(Get-Date)] Authentication failed: $_`n"
}

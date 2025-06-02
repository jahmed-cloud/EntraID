# --------------------------- CONFIGURABLE SETTINGS ---------------------------
$groupName = "Your Security Group Name"   # Filter users by this group
$filterDomain = ""                        # Optional: e.g. "contoso.com" or leave empty for all domains
$logAnalyticsEnabled = $false             # Set to $true to send logs to Log Analytics
$workspaceId = "<Your-LogAnalytics-WorkspaceID>"
$workspaceKey = "<Your-LogAnalytics-SharedKey>"
$logType = "UserAccessAudit"

# --------------------------- CONNECT TO MICROSOFT GRAPH ---------------------------
Import-Module Microsoft.Graph -MinimumVersion 2.0.0 -ErrorAction Stop
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All", "AuditLog.Read.All", "Application.Read.All", "AppRoleAssignment.Read.All"
Select-MgProfile -Name "beta"

# --------------------------- FETCH GROUP MEMBERS ---------------------------
$group = Get-MgGroup -Filter "displayName eq '$groupName'" -Property Id,DisplayName
if (-not $group) {
    Write-Error "Group '$groupName' not found."
    exit
}
$groupId = $group.Id
Write-Host "`n✔ Group '$($group.DisplayName)' found with ID: $groupId" -ForegroundColor Cyan

# Get group members
$members = Get-MgGroupMember -GroupId $groupId -All | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user' }

# --------------------------- PROCESS USERS ---------------------------
$results = @()
foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property "DisplayName,UserPrincipalName,UserType,AccountEnabled,CreatedDateTime,LastPasswordChangeDateTime,SignInActivity,Identities"
    
    if ($filterDomain -and ($user.UserPrincipalName -notlike "*@$filterDomain")) {
        continue
    }

    $isGuest = $user.UserType -eq "Guest"
    $isHybrid = $user.Identities | Where-Object {$_.SignInType -eq "onPremisesUserPrincipalName"} | Measure-Object | Select-Object -ExpandProperty Count
    $lastLogin = $user.SignInActivity.LastSignInDateTime
    $pwdLastChange = $user.LastPasswordChangeDateTime

    # App assignments
    $apps = Get-MgUserAppRoleAssignment -UserId $user.Id -ErrorAction SilentlyContinue | ForEach-Object {
        $sp = Get-MgServicePrincipal -ServicePrincipalId $_.ResourceId -ErrorAction SilentlyContinue
        if ($sp) { "$($sp.DisplayName) - Role: $($_.AppRoleId)" }
    }

    # Delegated access
    $delegatedApps = Get-MgUserOauth2PermissionGrant -UserId $user.Id -ErrorAction SilentlyContinue
    $delegateList = $delegatedApps | ForEach-Object { "$($_.ClientId) - Scope: $($_.Scope)" }

    # Roles
    $roles = Get-MgUserAppRoleAssignment -UserId $user.Id -ErrorAction SilentlyContinue | ForEach-Object {
        "App: $($_.ResourceDisplayName) - Role ID: $($_.AppRoleId)"
    }

    $obj = [PSCustomObject]@{
        DisplayName            = $user.DisplayName
        UserPrincipalName      = $user.UserPrincipalName
        UserType               = $user.UserType
        IsGuest                = $isGuest
        IsHybrid               = $isHybrid -gt 0
        LastLogin              = $lastLogin
        PasswordLastChanged    = $pwdLastChange
        AssignedApplications   = ($apps -join "; ")
        DelegatedPermissions   = ($delegateList -join "; ")
        RoleAssignments        = ($roles -join "; ")
        AccountEnabled         = $user.AccountEnabled
        CreatedDateTime        = $user.CreatedDateTime
    }

    $results += $obj

    # Optional: Log to Log Analytics
    if ($logAnalyticsEnabled) {
        Send-LogAnalyticsData -WorkspaceId $workspaceId -WorkspaceKey $workspaceKey -LogType $logType -Payload $obj
    }
}

# --------------------------- EXPORT TO CSV ---------------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath = "FilteredUserAccessReport_$timestamp.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Export completed: $csvPath" -ForegroundColor Green

# --------------------------- LOG ANALYTICS FUNCTION ---------------------------
function Send-LogAnalyticsData {
    param (
        [Parameter(Mandatory=$true)][string]$WorkspaceId,
        [Parameter(Mandatory=$true)][string]$WorkspaceKey,
        [Parameter(Mandatory=$true)][string]$LogType,
        [Parameter(Mandatory=$true)][psobject]$Payload
    )

    $json = $Payload | ConvertTo-Json -Depth 5 -Compress
    $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $date = (Get-Date).ToUniversalTime().ToString("r")
    $stringToHash = "POST\n$jsonBytes.Length\napplication/json\nx-ms-date:$date\n/api/logs"
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($WorkspaceKey)
    $hmacsha256 = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha256.Key = $keyBytes
    $hashedString = $hmacsha256.ComputeHash($bytesToHash)
    $signature = [Convert]::ToBase64String($hashedString)
    $authHeader = "SharedKey $WorkspaceId:$signature"

    $headers = @{
        "Authorization" = $authHeader
        "Log-Type" = $LogType
        "x-ms-date" = $date
        "Content-Type" = "application/json"
        "time-generated-field" = "LastLogin"
    }

    Invoke-RestMethod -Method Post -Uri "https://$WorkspaceId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01" -Headers $headers -Body $json
}

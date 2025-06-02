
# User Access Audit & Export Tool

This package contains a PowerShell script to export filtered user access audit data from Microsoft Entra ID (Azure AD) to a CSV file, with optional Log Analytics integration.

## 📦 Contents

- `Export-FilteredUserAccess.ps1`: Main script to run.
- `README.txt`: This documentation file.

## 🧰 Prerequisites

- PowerShell 7 or later recommended
- Microsoft.Graph PowerShell module (v2+)
- Proper delegated or application permissions to Microsoft Graph API

## 🔧 Configuration

Open `Export-FilteredUserAccess.ps1` and edit the following parameters:

- `$groupName`: Display name of the group to filter users.
- `$filterDomain`: Optional domain filter (e.g., "contoso.com"). Leave blank to include all domains.
- `$logAnalyticsEnabled`: Set to `$true` to send data to Log Analytics.
- `$workspaceId`, `$workspaceKey`: Required only if Log Analytics is enabled.

## ▶ How to Run

```powershell
# Install Microsoft.Graph module (if not already installed)
Install-Module Microsoft.Graph -Scope CurrentUser

# Run the script
.\Export-FilteredUserAccess.ps1
```

## ⏰ Automation (Optional)

- This script can be scheduled using Azure Automation.
- Ensure you use a Run As account or Managed Identity with the required Graph permissions.

## 📤 Output

- CSV file named like `FilteredUserAccessReport_YYYYMMDD_HHMMSS.csv` will be generated in the script's directory.

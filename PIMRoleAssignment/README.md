# Azure PIM Role Assignment Export Tool

## Overview
This script collects all PIM (Privileged Identity Management) role assignments—both Active and Eligible—across Azure AD and exports detailed and summary reports to CSV.

## Requirements
- PowerShell 7 or later
- Microsoft.Graph PowerShell SDK v2+
- Graph API permissions:
  - RoleManagement.Read.Directory
  - Directory.Read.All

## Usage

### Step 1: Install the Microsoft Graph Module
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Step 2: Run the Script
```powershell
.\PIMRoleAssignmentExport.ps1
```

### Output
- `PIM_Assignments_Details_<timestamp>.csv`: Full assignment details
- `PIM_Assignments_Summary_<timestamp>.csv`: Summary grouped by role and type

## Notes
- Supports debugging and verbose output.
- Automatically connects to the Microsoft Graph Beta endpoint.

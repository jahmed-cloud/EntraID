# Entra ID Guest User Management Script

## Overview
This PowerShell script helps manage **Guest Users** in Microsoft Entra ID (formerly Azure AD). It provides the ability to:

- **Find guest users** who have not accepted their invite.
- **Find guest users** who have not signed in for 30+ days.
- **Export user data** to CSV files.
- **Delete users** listed in the exported CSV files.
- **Log actions** for troubleshooting.

## Features
✅ Export guest users with **pending acceptance** to `PendingGuests.csv`  
✅ Export guest users **inactive for 30+ days** to `InactiveGuests.csv`  
✅ **Option to delete** guest users listed in CSV files  
✅ **Logs all actions** for auditing and troubleshooting  
✅ **Automates guest user management** in Microsoft Entra ID  

## Prerequisites
Before running the script, ensure the following:

1. **PowerShell 7+** (Recommended)
2. **Microsoft Graph PowerShell Module**  
   Install it using:
   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   ```
3. **Connect to Microsoft Graph with the required permissions:**
   ```powershell
   Connect-MgGraph -Scopes "User.Read.All", "User.ManageIdentities.All"
   ```
   Ensure your account has **Global Administrator** or **User Administrator** permissions.

## Installation & Setup
1. **Download the script** and place it in a directory. Example:  
   `C:\Entra ID\Guest Users`
2. Open **PowerShell as Administrator**.
3. Navigate to the script location:
   ```powershell
   cd "C:\Entra ID\Guest Users"
   ```
4. Run the script:
   ```powershell
   .\GuestUserManagement.ps1
   ```

## Usage Guide
When you run the script, it will present a menu with options:

```
===========================================
      Entra ID - Guest User Management     
===========================================
1. Export guest users who have not accepted the invite
2. Export guest users who have not signed in the last 30 days
3. Delete guest users from PendingGuests.csv
4. Delete guest users from InactiveGuests.csv
5. Exit
```

### **1️⃣ Export Pending Guest Users**
- This option exports **guest users who have not accepted their invite**.
- A file `PendingGuests.csv` is created in:
  ```
  C:\Entra ID\Guest Users
  ```
- Columns in CSV: `DisplayName`, `UserPrincipalName`, `CreatedDateTime`

### **2️⃣ Export Inactive Guest Users**
- This option exports **guest users who have not signed in for 30+ days**.
- A file `InactiveGuests.csv` is created in:
  ```
  C:\Entra ID\Guest Users
  ```
- Columns in CSV: `DisplayName`, `UserPrincipalName`, `SignInActivity`

### **3️⃣ Delete Users from PendingGuests.csv**
- Reads `PendingGuests.csv` and deletes the listed users.
- Each deletion is logged.

### **4️⃣ Delete Users from InactiveGuests.csv**
- Reads `InactiveGuests.csv` and deletes the listed users.
- Each deletion is logged.

### **5️⃣ Exit**
- Closes the script.

## Logging & Troubleshooting
- The script logs all actions to:
  ```
  C:\Entra ID\Guest Users\script_log.txt
  ```
- Example log entry:
  ```
  2025-02-24 12:00:15 - Exported inactive guests to InactiveGuests.csv
  2025-02-24 12:10:42 - Deleting guest user: user@example.com
  2025-02-24 12:11:00 - Error deleting guest user user@example.com: Insufficient privileges
  ```

## Author
👤 **Junaid Ahmed**  
🔗 GitHub: [jahmed-cloud](https://github.com/jahmed-cloud)

## License
This script is open-source and licensed under the **MIT License**.

---

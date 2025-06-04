# 🔄 Bulk Upload User Photos to Entra ID (Azure AD) via Microsoft Graph

This project provides a guide to bulk upload profile pictures for users in **Microsoft Entra ID (Azure Active Directory)** using **Microsoft Graph API** and **client credentials authentication**.

---

## 📋 Features

- Authenticate securely using **client credentials** (App ID, Secret, Tenant ID)
- Read user details and image paths from a CSV file
- Upload `.jpeg` profile pictures to Entra ID accounts
- Log success and failure actions for auditability

---
## 📁 Folder Structure

```bash
C:\Images\
├── userpic.csv       # Contains email and image path for each user
├── logs.log          # Will be auto-generated to store logs
├── upload-photos.ps1 # PowerShell script (excluded from this file)

```
## 🧾 Prerequisites
- PowerShell 5.1 or later
- App registration in Microsoft Entra ID (Azure AD):
  - Application (client) ID
  - Directory (tenant) ID
  - Client Secret
- Microsoft Graph API application permission:
- User.ReadWrite.All (must have admin consent granted)

## 🔧 CSV Format
Create a file named userpic.csv with the following format:

```bash
mail,path
user1@yourdomain.com,C:\Images\user1.jpg
user2@yourdomain.com,C:\Images\user2.jpg
```
mail: User Principal Name (email)
path: Full path to the .jpeg profile picture


## ▶️ How to Use
Update your PowerShell script (upload-photos.ps1) with:

  - Your Tenant ID
  - Client ID
  - Client Secret
  - CSV file path and log file path
  - Open PowerShell as Administrator and run the script: .\upload-photos.ps1
  - Monitor output and view detailed logs in logs.log.

## 🔐 Security Notes
Do not store secrets in version-controlled scripts.
Use environment variables or secure solutions (e.g., Azure Key Vault) in production environments.
Ensure your app registration has been granted admin consent for User.ReadWrite.All.

## ❓ Troubleshooting
Issue	Solution
401 Unauthorized	Ensure credentials are correct and permissions have admin consent
404 Not Found	User does not exist in Azure AD. Check email format in CSV
Image format error	Ensure images are valid .jpeg files (max 100 KB)

## 📄 License
MIT License

## 🤝 Contributing
Feel free to fork the repository, submit issues, or create pull requests for improvements.


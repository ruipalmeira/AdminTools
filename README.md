# Admin Toolkit 🔨📦🤖

## Overview 📝🔎
The **Admin Toolkit** is a collection of PowerShell scripts for managing and auditing Active Directory environments.  
It helps IT administrators automate common tasks, enforce policies, and generate reports safely and efficiently.

### **Key Features :** ⚙️✨
#### AD_User Set PasswordNeverExpires flag - SetPasswordNeverExpires.ps1
- Purpose: Sets `PasswordNeverExpires` for users in nested OUs with optional recursion and Audit users’ `PasswordNeverExpires` flag across the entire domain.
- Features:
  - Logs changes and audit reports to CSV files with proper UTF-8 encoding.
  - Skips likely service accounts automatically to prevent accidental changes.
  - Safe and interactive prompts with confirmations before making modifications.
#### AD User Export Script - AD_UserExtract.ps1
- Purpose: Export users from Active Directory to CSV for reporting or auditing.
- Features:
  - Interactive OU selection with support for child OUs.
  - Option to include/exclude sub-OUs.
  - Retrieves key user attributes: SamAccountName, DisplayName, Email, Enabled, LastLogonDate, Office, and OU. 
  - Creates an audit log recording: who ran the script, which OU was exported, number of users, and timestamp. 
  - UTF8-encoded CSV output supporting special characters.
#### SharePoint Site Group Export Script - SharePoint_GroupExtract.ps1
- Purpose: Extract SharePoint Online site groups using PnP.PowerShell.
- Features: 
  - Connects via Entra ID App Registration (``ClientId``) with delegated permissions for Graph and SharePoint.
  - Retrieves all site groups: ``Title``, ``Id``, ``LoginName``, ``OwnerTitle``, ``OnlyAllowMembersViewMembership``.
  - Exports to CSV and maintains **audit logging** with site URL, output file, admin, and timestamp.
  - Handles MFA or device login securely.
#### SharePoint Group Membership Export Script - SharePoint_GroupMembershipExtract.ps1
  - Purpose: Export each SharePoint site group and its members to CSV.
  - Features: 
    - Connects using Entra ID App Registration with interactive login.
    - Loops through all site groups and retrieves members for each.
    - Captures: ``GroupName``, ``GroupId``, ``Member Name``, ``LoginName``, ``Email``.
    - Handles groups with **no members** gracefully.
    - Outputs a membership CSV and updates an audit log including site, output file, and timestamp.
    - Provides clear console feedback while processing each group.
---

## Quick Reference 🎯⚡

| Script | Purpose |
|--------|---------|
| `Set-PasswordNeverExpires.ps1` | Set or unset PasswordNeverExpires flag for users across nested OUs |
| `AD_UserExtract.ps1` | Export users from Active Directory to CSV for reporting or auditing. |
| `SharePoint_GroupExtract.ps1` | Extract SharePoint Online site groups using PnPPowerShell. |
| `SharePoint_GroupMembershipExtract.ps1` | Export each SharePoint site group and its members to CSV |

---

## Folder Structure 📁🗄️

AdminToolkit/  
├─ scripts/  
│   ├─ SetPasswordNeverExpires.ps1  
│   ├─ AD_GroupExtract.ps1  
│   ├─ Sharepoint_GroupExtract.ps1  
│   └─ SharePoint_GroupMembershipExtract.ps1  
├─ logs/  
├─ docs/  
├─ .gitignore  
└─ README.md

---

## Prerequisites 🛠️🚀

- Windows Server or Windows 10/11 with the **ActiveDirectory** module installed  
- PowerShell 5.1+ or PowerShell 7+ recommended  
- Appropriate AD privileges for user management and read access  
- Git (optional, if using version control)

---

## Setup ⚙️⚙️

- ✅ Clone the repository: 
~~~powershell 
git clone https://github.com/ruipalmeira/AdminToolkit.git
~~~
- ✅ Unblock the scripts if necessary:
~~~powershell 
Get-ChildItem .\scripts*.ps1 | Unblock-File
~~~
- ✅ Ensure `logs` folder exists (scripts create it automatically if missing): 
~~~powershell 
mkdir C:\AdminTools\Logs
~~~

---

## Usage 🔨🔨

### 1. Set PasswordNeverExpires for Users

- Script: `Set-PasswordNeverExpires.ps1`  
- Features:
  - Interactive OU navigation
  - Optional recursion into sub-OUs
  - Automatically excludes likely service accounts
  - Prompts for ENABLE/DISABLE
  - Generates CSV log of changes

Example:
~~~powershell
cd C:\AdminTools\scripts
.\Set-PasswordNeverExpires.ps1
~~~

---

### 2. Audit PasswordNeverExpires Across Domain 🔎🕵️

- Script: `Audit-PasswordNeverExpires.ps1`  
- Features:
  - Scans all users across the domain
  - Exports a CSV audit report with:

| Column | Description |
|--------|------------|
| `DateTime` | Timestamp of the audit entry |
| `Admin` | Username of the admin who ran the script |
| `SamAccountName` | User account name |
| `DisplayName` | User’s full name |
| `OU` | Organizational Unit location |
| `PasswordNeverExpires` | True/False |
| `PasswordLastSet` | Date the password was last set |
| `Description` | Any description field from AD |

- Handles special characters with UTF-8 encoding

Example:
~~~powershell
cd C:\AdminTools\scripts
.\Audit-PasswordNeverExpires.ps1
~~~
---

## Logging 📄📄

- Logs and CSV files are stored in the `logs/` folder  
- CSV files are timestamped for easy tracking  

---

## Best Practices ✔️🟢

- Test scripts in a lab before production  
- Keep `logs/` folder out of Git to avoid committing sensitive data  
- Commit scripts and README updates regularly  
- Add new scripts under `scripts/` and document usage in `docs/`  

---

## Contributing 🏗️🛠️
#### 1. Fork the repository  
#### 2. Create a branch for your feature or fix:
~~~powershell
git checkout -b feature/new-script
~~~
#### 3. Commit your changes with descriptive messages  
#### 4. Push your branch and create a pull request

---

## License ©️🧑‍⚖️

CC BY-NC-SA 4.0 – [Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/)
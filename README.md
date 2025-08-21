# Admin Toolkit 🔨📦🤖

## Overview 📝🔎
The **Admin Toolkit** is a collection of PowerShell scripts for managing and auditing Active Directory environments.  
It helps IT administrators automate common tasks, enforce policies, and generate reports safely and efficiently.

### **Key Features :** ⚙️✨
- Set `PasswordNeverExpires` for users in nested OUs with optional recursion.
- Audit users’ `PasswordNeverExpires` flag across the entire domain.
- Logs changes and audit reports to CSV files with proper UTF-8 encoding.
- Skips likely service accounts automatically to prevent accidental changes.
- Safe and interactive prompts with confirmations before making modifications.

---

## Quick Reference 🎯⚡

| Script | Purpose |
|--------|---------|
| `Set-PasswordNeverExpires.ps1` | Set or unset PasswordNeverExpires flag for users across nested OUs |
| `Audit-PasswordNeverExpires.ps1` | Audit all users’ PasswordNeverExpires flag domain-wide and export CSV |
| `OtherScripts.ps1` | Placeholder for future scripts |

---

## Folder Structure 📁🗄️

AdminToolkit/  
├─ scripts/  
│   ├─ Set-PasswordNeverExpires.ps1  
│   ├─ Audit-PasswordNeverExpires.ps1  
│   └─ OtherScripts.ps1  
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
git clone https://github.com/yourusername/AdminToolkit.git
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

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
- Appropriate AD privileges
- PnP.PowerShell module for SharePoint scripts
- Entra ID App Registration (ClientId) with delegated permissions for SharePoint scripts
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
### 2. Export AD Users 👥📋
- Script: `AD_UserExtract.ps1`  
- Features:
  - Interactive OU selection with support for child OUs.
  - Option to include/exclude sub-OUs.
  - Retrieves key user attributes: `SamAccountName`, `DisplayName`, `Email`, `Enabled`, `LastLogonDate`, `Office`, and OU.  
  - Creates an audit log recording: who ran the script, which OU was exported, number of users, and timestamp.  
  - UTF8-encoded CSV output supporting special characters.

Example:
~~~powershell
cd C:\AdminTools\scripts
.\AD_UserExtract.ps1
~~~
---
### 3. Export SharePoint Site Groups 🏢📋
- Script: `SharePoint_GroupExtract.ps1`  
- Features:
  - Connects to SharePoint Online site using Entra ID App Registration
  - Retrieves all site groups and key properties
  - Exports to CSV and creates audit log

Example:
~~~powershell
cd C:\AdminTools\scripts
.\SharePoint_GroupExtract.ps1
~~~

---

### 4. Export SharePoint Group Memberships 🧑‍🤝‍🧑📋
- Script: `SharePoint_GroupMembershipExtract.ps1`  
- Features:
  - Connects interactively with Entra ID App Registration
  - Loops through each site group and exports members to CSV
  - Updates audit log for each run

Example:
~~~powershell
cd C:\AdminTools\scripts
.\SharePoint_GroupMembershipExtract.ps1
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
## Admin Toolkit Flowchart 🗂️📊

```mermaid
flowchart TD
    A["Admin Toolkit Scripts"]:::main
    B["AD User Export Script"]:::ad
    C["AD Group Export Script"]:::ad
    D["SharePoint Site Group Export Script"]:::sp
    E["SharePoint Group Membership Export Script"]:::sp

    F["CSV: Users Attributes (SamAccountName, Name, Email, Office)"]:::csv
    G["CSV: Groups Attributes (Name, Scope, Description, OU)"]:::csv
    H["CSV: Site Groups Attributes (Title, Owner, OnlyAllowMembersViewMembership)"]:::csv
    I["CSV: Group Members (GroupName, Member, LoginName, Email)"]:::csv

    J["Audit Log CSV (Admin, Timestamp, Scope, Output File, Count, Action)"]:::log

    A --> B
    A --> C
    A --> D
    D --> E

    B --> F
    C --> G
    D --> H
    E --> I

    F --> J
    G --> J
    H --> J
    I --> J

    classDef main fill:#f9f,stroke:#333,stroke-width:2px,color:#000;
    classDef ad fill:#9be3ff,stroke:#333,stroke-width:1px,color:#000;
    classDef sp fill:#ffdab9,stroke:#333,stroke-width:1px,color:#000;
    classDef csv fill:#d4f4dd,stroke:#333,stroke-width:1px,color:#000;
    classDef log fill:#ffe699,stroke:#333,stroke-width:2px,color:#000;

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
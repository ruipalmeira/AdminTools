<#
.SYNOPSIS
    Extract users from Active Directory by Organizational Unit (OU).

.DESCRIPTION
    This script allows an admin to interactively browse OUs (with support for child OUs),
    select one, and export all users from that OU to a CSV file.
    Includes Office field (physicalDeliveryOfficeName).
    Also generates an audit log with who ran the script, when, which OU, and how many users were exported.

.NOTES
    Author: Admin Toolkit
    Version: 1.2
#>

Import-Module ActiveDirectory

# === Paths ===
$logFolder = "C:\AdminTools\Logs"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

$auditLog = Join-Path $logFolder "AuditLog.csv"

# === Function: OU Selection ===
function Select-OU {
    param (
        [string]$SearchBase = ""
    )

    # Get OUs under the search base
    if ($SearchBase) {
        $OUs = Get-ADOrganizationalUnit -SearchBase $SearchBase -SearchScope OneLevel -Filter * | Sort-Object Name
    } else {
        $OUs = Get-ADOrganizationalUnit -Filter * | Sort-Object Name
    }

    if (-not $OUs) {
        Write-Host "No child OUs found under: $SearchBase" -ForegroundColor Yellow
        return $SearchBase
    }

    # Show options
    for ($i = 0; $i -lt $OUs.Count; $i++) {
        Write-Host "[$i] $($OUs[$i].Name)"
    }
    Write-Host "[x] Select this OU ($SearchBase)" -ForegroundColor Cyan

    $choice = Read-Host "Select an OU index or [x] to stop"
    if ($choice -eq "x") {
        return $SearchBase
    } elseif ($choice -match '^\d+$' -and [int]$choice -ge 0 -and [int]$choice -lt $OUs.Count) {
        return Select-OU -SearchBase $OUs[$choice].DistinguishedName
    } else {
        Write-Host "Invalid choice, try again." -ForegroundColor Red
        return Select-OU -SearchBase $SearchBase
    }
}

# === Main Script ===
Write-Host "=== Active Directory User Export Tool ===" -ForegroundColor Green
$selectedOU = Select-OU
if (-not $selectedOU) {
    Write-Host "No OU selected. Exiting..." -ForegroundColor Red
    exit
}

$recurse = Read-Host "Include child OUs? (y/n)"
$searchScope = if ($recurse -eq "y") { "Subtree" } else { "OneLevel" }

Write-Host "Exporting users from OU: $selectedOU" -ForegroundColor Cyan

# Get users
$users = Get-ADUser -SearchBase $selectedOU -SearchScope $searchScope -Filter * `
    -Properties DisplayName,mail,Enabled,LastLogonDate,physicalDeliveryOfficeName |
    Select-Object SamAccountName,
                  DisplayName,
                  mail,
                  Enabled,
                  LastLogonDate,
                  @{Name="Office";Expression={$_.physicalDeliveryOfficeName}},
                  @{Name="OU";Expression={($_.DistinguishedName -split ",",2)[1]}}

$userCount = $users.Count

# Save to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvFile = Join-Path $logFolder "ADUsers_$timestamp.csv"

$users | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

Write-Host "Export complete. $userCount users saved to: $csvFile" -ForegroundColor Green

# === Audit Log ===
$auditEntry = [PSCustomObject]@{
    DateTime   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Admin      = $env:USERNAME
    OU         = $selectedOU
    Recurse    = if ($searchScope -eq "Subtree") { "Yes" } else { "No" }
    OutputFile = $csvFile
    UserCount  = $userCount
    Action     = "Export AD Users"
}

# If audit log doesn’t exist, create with headers
if (-not (Test-Path $auditLog)) {
    $auditEntry | Export-Csv -Path $auditLog -NoTypeInformation -Encoding UTF8
} else {
    $auditEntry | Export-Csv -Path $auditLog -NoTypeInformation -Encoding UTF8 -Append
}

Write-Host "Audit log updated: $auditLog" -ForegroundColor Yellow
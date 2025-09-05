<#
.SYNOPSIS
    Export Active Directory groups by Organizational Unit (OU).

.DESCRIPTION
    Allows admin to select an OU (with optional recursion) and export all groups found.
    Exports to CSV and also logs the action to an audit file.

.NOTES
    Author: Admin Toolkit
    Version: 1.0
#>

Import-Module ActiveDirectory

# === Paths ===
$logFolder = "C:\AdminTools\Logs"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

$auditLog = Join-Path $logFolder "AuditLog_Groups.csv"

# === Function: OU Selection ===
function Select-OU {
    param ([string]$SearchBase = "")

    if ($SearchBase) {
        $OUs = Get-ADOrganizationalUnit -SearchBase $SearchBase -SearchScope OneLevel -Filter * | Sort-Object Name
    } else {
        $OUs = Get-ADOrganizationalUnit -Filter * | Sort-Object Name
    }

    if (-not $OUs) {
        Write-Host "No child OUs found under: $SearchBase" -ForegroundColor Yellow
        return $SearchBase
    }

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
Write-Host "=== Active Directory Group Export Tool ===" -ForegroundColor Green
$selectedOU = Select-OU
if (-not $selectedOU) {
    Write-Host "No OU selected. Exiting..." -ForegroundColor Red
    exit
}

$recurse = Read-Host "Include child OUs? (y/n)"
$searchScope = if ($recurse -eq "y") { "Subtree" } else { "OneLevel" }

Write-Host "Exporting groups from OU: $selectedOU" -ForegroundColor Cyan

# Get groups
$groups = Get-ADGroup -SearchBase $selectedOU -SearchScope $searchScope -Filter * -Properties Description,whenCreated,whenChanged |
    Select-Object Name,
                  Description,
                  GroupScope,
                  GroupCategory,
                  whenCreated,
                  whenChanged,
                  @{Name="OU";Expression={($_.DistinguishedName -split ",",2)[1]}}

$groupCount = $groups.Count

# Save to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvFile = Join-Path $logFolder "ADGroups_$timestamp.csv"

$groups | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8

Write-Host "Export complete. $groupCount groups saved to: $csvFile" -ForegroundColor Green

# === Audit Log ===
$auditEntry = [PSCustomObject]@{
    DateTime   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Admin      = $env:USERNAME
    OU         = $selectedOU
    Recurse    = if ($searchScope -eq "Subtree") { "Yes" } else { "No" }
    OutputFile = $csvFile
    GroupCount = $groupCount
    Action     = "Export AD Groups"
}

if (-not (Test-Path $auditLog)) {
    $auditEntry | Export-Csv -Path $auditLog -NoTypeInformation -Encoding UTF8
} else {
    $auditEntry | Export-Csv -Path $auditLog -NoTypeInformation -Encoding UTF8 -Append
}

Write-Host "Audit log updated: $auditLog" -ForegroundColor Yellow
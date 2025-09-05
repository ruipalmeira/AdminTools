<#
.SYNOPSIS
    Export SharePoint site groups to CSV with audit logging.

.DESCRIPTION
    Connects to a SharePoint Online site using Entra ID App Registration (ClientId)
    and exports the list of groups to CSV.
    Also logs the extraction action to a separate audit CSV.

.NOTES
    Requires:
    - PnP.PowerShell module
    - Entra ID App Registration with API permissions:
        Microsoft Graph -> Group.Read.All (Delegated)
        SharePoint -> Sites.Read.All (Delegated)
#>

# === VARIABLES ===
$SiteUrl   = "https://aquinos365.sharepoint.com/sites/YourSite" # # replace with correct sharepoint site
$ClientId  = "YOUR-APP-REGISTRATION-ID"   # replace with your Entra ID App Client ID

$sysFolder = "C:\AD_AuditLogs"

$exportFolder = $sysFolder
$timestamp    = Get-Date -Format "yyyyMMdd_HHmmss"

$groupExport  = Join-Path $exportFolder "SharePointGroups_$timestamp.csv"
$auditLog     = Join-Path $exportFolder "AuditLog.csv"

# === PREPARE FOLDER ===
if (!(Test-Path $exportFolder)) {
    New-Item -ItemType Directory -Path $exportFolder | Out-Null
}

# === CONNECT TO SHAREPOINT ===
try {
    Write-Host "Connecting to SharePoint..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive
    Write-Host "Connected successfully." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Could not connect to SharePoint. $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# === EXPORT GROUPS ===
try {
    $groups = Get-PnPGroup
    if ($groups.Count -eq 0) {
        Write-Host "No groups found in site." -ForegroundColor Yellow
    }
    else {
        $groups | Select-Object Title,Id,LoginName,OwnerTitle,OnlyAllowMembersViewMembership |
            Export-Csv -Path $groupExport -NoTypeInformation -Encoding UTF8

        Write-Host "Export completed: $groupExport" -ForegroundColor Green
    }
}
catch {
    Write-Host "ERROR: Could not retrieve groups. $($_.Exception.Message)" -ForegroundColor Red
}

# === AUDIT LOG ===
$auditEntry = [PSCustomObject]@{
    DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Admin    = $env:USERNAME
    Action   = "SharePoint Groups Export"
    Site     = $SiteUrl
    Output   = $groupExport
}

$auditEntry | Export-Csv -Path $auditLog -NoTypeInformation -Append -Encoding UTF8
Write-Host "Audit log updated: $auditLog" -ForegroundColor Cyan
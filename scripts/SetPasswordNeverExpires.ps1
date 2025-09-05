<#
.SYNOPSIS
    Export SharePoint site groups and their memberships to CSV with audit logging.

.DESCRIPTION
    Connects to a SharePoint Online site using Entra ID App Registration (ClientId).
    Exports all groups and their members into a CSV file.
    Logs the extraction action to an audit CSV.

.NOTES
    Requires:
    - PnP.PowerShell module
    - Entra ID App Registration with API permissions:
        Microsoft Graph -> Group.Read.All (Delegated)
        SharePoint -> Sites.Read.All (Delegated)
#>

# === VARIABLES ===
$SiteUrl   = "https://aquinos365.sharepoint.com/sites/YourSite"
$ClientId  = "YOUR-APP-REGISTRATION-ID"   # replace with your Entra ID App Client ID

$exportFolder = "C:\AD_AuditLogs"
$timestamp    = Get-Date -Format "yyyyMMdd_HHmmss"

$groupExport  = Join-Path $exportFolder "SharePointGroupMemberships_$timestamp.csv"
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

# === EXPORT GROUPS AND MEMBERS ===
$results = @()

try {
    $groups = Get-PnPGroup
    if ($groups.Count -eq 0) {
        Write-Host "No groups found in site." -ForegroundColor Yellow
    }
    else {
        foreach ($group in $groups) {
            Write-Host "Processing group: $($group.Title)" -ForegroundColor Cyan
            try {
                $members = Get-PnPGroupMember -Identity $group
                if ($members.Count -eq 0) {
                    $results += [PSCustomObject]@{
                        GroupName = $group.Title
                        GroupId   = $group.Id
                        Member    = "<No Members>"
                        LoginName = ""
                        Email     = ""
                    }
                }
                else {
                    foreach ($member in $members) {
                        $results += [PSCustomObject]@{
                            GroupName = $group.Title
                            GroupId   = $group.Id
                            Member    = $member.Title
                            LoginName = $member.LoginName
                            Email     = $member.Email
                        }
                    }
                }
            }
            catch {
                Write-Host "Error retrieving members for group $($group.Title): $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        $results | Export-Csv -Path $groupExport -NoTypeInformation -Encoding UTF8
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
    Action   = "SharePoint Group Membership Export"
    Site     = $SiteUrl
    Output   = $groupExport
}

$auditEntry | Export-Csv -Path $auditLog -NoTypeInformation -Append -Encoding UTF8
Write-Host "Audit log updated: $auditLog" -ForegroundColor Cyan
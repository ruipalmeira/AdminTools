<#
.SYNOPSIS
    Logs PasswordNeverExpires state for all users in the domain to a CSV.
.DESCRIPTION
    Automatically discovers all users across all OUs, collects their
    PasswordNeverExpires state, last password set date, and logs it to CSV.
    Creates log folder at runtime if it doesn't exist.
#>

Import-Module ActiveDirectory

# --- CONFIG ---
# Log folder
$logFolder = "C:\AdminTools\Logs"

# Create log folder if it doesn't exist
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
    Write-Host "Created log folder: $logFolder" -ForegroundColor Green
}

# CSV file path with timestamp
$csvFile = "$logFolder\PasswordNeverExpires_Audit_$(Get-Date -Format yyyyMMdd_HHmmss).csv"

# --- SCRIPT ---
# Get all users in the domain
$users = Get-ADUser -Filter * -Properties PasswordNeverExpires, PasswordLastSet, Description, DistinguishedName

if ($users.Count -eq 0) {
    Write-Host "No users found in the domain." -ForegroundColor Yellow
    exit
}

# Prepare audit objects
$auditEntries = foreach ($user in $users) {
    [PSCustomObject]@{
        DateTime             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        SamAccountName       = $user.SamAccountName
        DisplayName          = $user.Name
        OU                   = ($user.DistinguishedName -replace '^.+?,(OU=.+)$','$1') # Extract OU part
        PasswordNeverExpires = $user.PasswordNeverExpires
        PasswordLastSet      = $user.PasswordLastSet
        Description          = $user.Description
    }
}

# Export to CSV
$auditEntries | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8BOM

Write-Host "Audit completed. CSV saved to $csvFile" -ForegroundColor Green
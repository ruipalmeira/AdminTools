<#
.SYNOPSIS
    Manage "Password Never Expires" for users in nested OUs while skipping service accounts.
.DESCRIPTION
    Starts from OUs with "Users" in the name and allows drilling down through multiple levels
    of child OUs until the admin selects where to apply changes. Admin can choose ENABLE or
    DISABLE for PasswordNeverExpires. Script automatically excludes likely service accounts.
#>

# Define log folder and CSV file
$logFolder = "C:\AdminTools\Logs"
if (-not (Test-Path $logFolder)) { New-Item -Path $logFolder -ItemType Directory }
$logCsv = "$logFolder\PasswordNeverExpires.csv"

Import-Module ActiveDirectory
$OUs = @($OUs)
function Select-OURecursively {
    param (
        [string]$StartOU = ""
    )

    if ($StartOU) {
        $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $StartOU -SearchScope OneLevel | Sort-Object Name
    }
    else {
        $OUs = Get-ADOrganizationalUnit -Filter 'Name -like "*Users*"' | Sort-Object Name
    }

    # Force $OUs to be an array, even if empty
    $OUs = @($OUs)

    if ($OUs.Count -eq 0) {
        Write-Host "`nNo further child OUs found." -ForegroundColor Yellow
        return $StartOU
    }

    Write-Host "`nAvailable OUs:" -ForegroundColor Cyan
    Write-Host "---------------------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    for ($i=0; $i -lt $OUs.Count; $i++) {
        Write-Host "[$i] $($OUs[$i].Name)  -->  $($OUs[$i].DistinguishedName)"
    }
    Write-Host "---------------------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "`n[P] Pick current OU ($StartOU) and stop here"

    $choice = Read-Host "Select an OU number to drill deeper, or 'P' to pick the current OU"

    if ($choice -eq "P" -or $choice -eq "p") {
        return $StartOU
    }
    elseif ($choice -match '^\d+$' -and [int]$choice -ge 0 -and [int]$choice -lt $OUs.Count) {
        return Select-OURecursively -StartOU $OUs[$choice].DistinguishedName
    }
    else {
        Write-Host "Invalid selection. Exiting." -ForegroundColor Red
        exit
    }
}

# Step 1: Select OU (with recursive navigation)
$finalOU = Select-OURecursively

if (-not $finalOU) {
    Write-Host "No OU selected. Exiting." -ForegroundColor Red
    exit
}

Write-Host "`nYou selected: $finalOU" -ForegroundColor Yellow

# Step 2: Ask recursion preference
$recChoice = Read-Host "Do you want to include all sub-OUs under this OU? (Y/N)"
$recursive = ($recChoice -in @("Y","y"))

# Step 3: Ask whether to enable or disable
$action = Read-Host "Do you want to ENABLE or DISABLE 'Password Never Expires'? (Enter ENABLE/DISABLE)"
switch ($action.ToUpper()) {
    "ENABLE" { $setValue = $true }
    "DISABLE" { $setValue = $false }
    default {
        Write-Host "Invalid action. Exiting." -ForegroundColor Red
        exit
    }
}

# Step 4: Get users
$searchScope = if ($recursive) { "Subtree" } else { "OneLevel" }
$users = Get-ADUser -SearchBase $finalOU -SearchScope $searchScope -Filter * -Properties PasswordNeverExpires, Description, PasswordLastSet

if ($users.Count -eq 0) {
    Write-Host "No users found in the selected OU." -ForegroundColor Yellow
    exit
}

# Step 5: Identify likely service accounts and exclude them
$serviceAccounts = $users | Where-Object {
    ($_.PasswordLastSet -lt (Get-Date).AddYears(-2)) -or
    ($_.PasswordNeverExpires -eq $true) -or
    ($_.Description -match "service|account|app|printer|sql")
}

$realUsers = $users | Where-Object { $_ -notin $serviceAccounts }

Write-Host "`nTotal users found: $($users.Count)" -ForegroundColor Cyan
Write-Host "Excluded likely service accounts: $($serviceAccounts.Count)" -ForegroundColor Magenta
Write-Host "Users to be updated: $($realUsers.Count)" -ForegroundColor Green

if ($serviceAccounts.Count -gt 0) {
    Write-Host "`nExamples of excluded service accounts:" -ForegroundColor DarkYellow
    $serviceAccounts | Select-Object SamAccountName, Description, PasswordNeverExpires, PasswordLastSet | Format-Table -AutoSize
}

# Step 6: Confirm operation
$confirm = Read-Host "`nDo you want to continue and set PasswordNeverExpires=$setValue for the selected users? (Y/N)"
if ($confirm -notin @("Y","y")) {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

# Step 7: Apply changes to real users
foreach ($user in $realUsers) {
    Set-ADUser $user -PasswordNeverExpires $setValue
    Write-Host "Updated: $($user.SamAccountName)" -ForegroundColor Green
     # Create a log entry object
    $logEntry = [PSCustomObject]@{
      DateTime   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      Admin      = $env:USERNAME
      User       = $user.SamAccountName
      OU         = $finalOU
      Action     = if ($setValue) { "Enabled" } else { "Disabled" }
    }
    # Append to CSV
    $logEntry | Export-Csv -Path $logCsv -NoTypeInformation -Append
}

foreach ($user in $realUsers) {
    Set-ADUser $user -PasswordNeverExpires $setValue
    Write-Host "Updated: $($user.SamAccountName)" -ForegroundColor Green
     # Create a log entry object
    $logEntry = [PSCustomObject]@{
      DateTime   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      Admin      = $env:USERNAME
      User       = $user.SamAccountName
      OU         = $finalOU
      Action     = if ($setValue) { "Enabled" } else { "Disabled" }
    }
    # Append to CSV
$logEntry | Export-Csv -Path $logCsv -NoTypeInformation -Append
  foreach ($svcUser in $serviceAccounts) {
  $logEntry = [PSCustomObject]@{
      DateTime   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      Admin      = $env:USERNAME
      User       = $svcUser.SamAccountName
      OU         = $finalOU
      Action     = "Skipped (likely service account)"
  }
  $logEntry | Export-Csv -Path $logCsv -NoTypeInformation -Append
  }
}

Write-Host "`nOperation complete. PasswordNeverExpires set to $setValue for $($realUsers.Count) users in $finalOU (recursive=$recursive)." -ForegroundColor Cyan
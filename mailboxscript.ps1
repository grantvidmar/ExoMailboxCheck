<#
.SYNOPSIS
    This script is to view the total mailbox dispersment for CC users. It will be used by SD to check if a user has a full Hidden Recyclebin.
    The script will launch a PS shell via admin privledges. It will then install and load the required cmdlet.
    SD agent will be required to enter user UPN. It will then return the results that will need to be copied to INC.

.DESCRIPTION
    This script is to view the total mailbox dispersment for CC users. It will be used by SD to check if a user has a full Hidden Recyclebin.
    The script will launch a PS shell via admin privledges. It will then install and load the required cmdlet.
    SD agent will be required to enter user UPN. It will then return the results that will need to be copied to INC.

.INPUTS
   $usermailbox = Read-Host "Enter the user mailbox email address"

.OUTPUTS
   Detailed information of the users Outlook available storage.

.EXAMPLE
   right click "Run with PowerShell", admin prompt, enter user UPN, Copy output to INC

.NOTES
    please reach out to GVidmar for any issues.

    === SCRIPT ===
    2023-08-01   Mailbox   1.0   Initial release
    ==============

#>
# ---------------------------------------------------------------------------------------------------------------------------------------------------



# Check if the script is running with elevated privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If not running as admin, relaunch the script with elevated privileges
if (-not $isAdmin)
{
    Write-Host "This script requires elevated privileges. Restarting script with administrative privileges..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Path)
    Exit
}

# Set the name of the required module.
$requiredModule = "ExchangeOnlineManagement"

# Check if the module is installed.
$module = Get-Module -ListAvailable -Name $requiredModule

# If the module is not installed, install it.
if ($module.Count -eq 0) {
    Install-Module -Name $requiredModule
}

# Import the Exchange Online PowerShell module.
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline -ShowBanner

# Prompt for user mailbox
$usermailbox = Read-Host "Enter the user mailbox email address"

# Get mailbox folder statistics for Recoverable Items folder
$folderStats = Get-MailboxFolderStatistics $usermailbox -FolderScope RecoverableItems

# Display the required properties
$folderStats | Select-Object Name, FolderAndSubfolderSize, ItemsInFolderAndSubfolders | Format-List


Read-Host -Prompt "Please copy this information to the ticket"
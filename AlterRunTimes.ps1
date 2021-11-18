Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# Site configuration
$SiteCode = "" # Site code 
$ProviderMachineName = "Primary site server" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line
# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams }                                                                       
# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) { New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams}
# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams
###########################################################################################################
Get-CMSoftwareUpdate -Name "*Cumulative*" -Fast | Set-CMSoftwareUpdate -MaximumExecutionMins 180 #-Verbose

Get-CMSoftwareUpdate -Name "*Rollup*" -Fast | Set-CMSoftwareUpdate -MaximumExecutionMins 180 #-Verbose

Get-CMSoftwareUpdate -Name "*SQL*" -Fast | Set-CMSoftwareUpdate -MaximumExecutionMins 180

Get-CMSoftwareUpdate -Name "*Defender*" -Fast | Set-CMSoftwareUpdate -MaximumExecutionMins 180

Get-CMSoftwareUpdate -Name "*Security*" -Fast | Set-CMSoftwareUpdate -MaximumExecutionMins 180

Get-CMSoftwareUpdate -ArticleID "Q*" -Fast | Set-CMSoftwareUpdate -MaximumExecutionMins 120
##Variables
$serverName
$option
$loop
$drive
$driveLetter
$usrInput

##Functions
<#
.SYNOPSIS
Main method. Directs the user.

.DESCRIPTION
Directs the user to the correct function and does some error prevention.

.NOTES
Move error correction to functions to make more modular.
#>
function main {
    param ()
    Write-Host "Pick from the Following options:"
    Write-Host "     1, Basic DISM (Local)"
    Write-Host "     2, Advanced DISM Image Restoration (Local)"
    Write-Host "     3, Basic DISM (Remote)"
    Write-Host "     4, Advanced DISM Image Restoration (Remote)"
    Write-Host "     5, Help"
    $option = Read-Host "Choice"
    switch ($option) {
        1 { basicDISM }
        2 { advancedDISM }
        3 {          
            $serverName = Read-Host "Enter Server Name"
            Write-Progress "Checking Server Connection..."
            if (checkServer $serverName) {
                Write-Host "Server Connection Successful."
                basicDISMRemote $serverName
            }
            else {Write-Warning "Could not establish connection with $serverName. Make sure the server online."}
        }
        4 {
            $serverName = Read-Host "Enter Server Name"
            Write-Progress "Checking Server Connection..."
            if (checkServer $serverName) {
                Write-Host "Server Connection Successful."
                advancedDISMRemote $serverName
            }
            else {Write-Warning "Could not establish connection with $serverName. Make sure the server online."}
        }
        5 {
            Write-Host "1, Basic DISM (Local)"
            Write-Host "    Runs CHKDSK /F then three DISM commands in sequence followed by SFC /ScanNow on the current device."
            Write-Host "    Command a, 'CHKDSK /F' searches for and fixes any disk related errors."
            Write-Host "    Command b, 'DISM.exe /Online /Cleanup-image /Scanhealth' - An in-depth check to see if the OS has any issues or corruption."
            Write-Host "    Command c, 'DISM.exe /Online /Cleanup-image /Restorehealth' - If any problems are identified by the previous command, this command attempts to repair common issues automatically."
            Write-Host "    Command d, 'DISM.exe /online /cleanup-image /StartComponentCleanup' - Attempts to remove or fix any inconsistent or supercseded components in the Windows Component Store (WinSxS Folder)."
            Write-Host "    Command e, 'SFC /ScanNow' - Scans all protected system files and replaces corrupted files with a cached copy."
            Write-Host ""
            Write-Host "2, Advanced DISM (Local)"
            Write-Host "    Uses an 'known good' OS image to try repair any issues with the current OS image. An external OS specific Windows ISO needs to be mounted to the effected device for this to work."
            Write-Host "    Command a, Dism /Online /Cleanup-Image /RestoreHealth /Source:X:\sources\install.wim"
            Write-Host ""
            Write-Host "3, Basic DISM (Remote)"
            Write-Host "    Same as the basic commands but executed on a remote server specified by you."
            Write-Host ""
            Write-Host "4, Advanced DISM (Remote)"
            Write-Host "    Same as the basic commands but executed on a remote server specified by you. You will need to mount the correct ISO, the script will work out the correct drive letter for the mounted ISO."
            Write-Host ""
        }
        Default { 
            Write-Warning "Incorrect Option."
            $loop = Read-Host "Try again? [Y/N]"
            if ($loop.ToUpper() -eq "Y")  {main}
            else {Write-Host "Exiting..."}
        }
    }
}

<#
.SYNOPSIS
Checks connection to user specified server.

.DESCRIPTION
Uses the PowerShell command Test-Connection to send an ICMP request to the user specified server 3 times. If the connection is successful then it returns true. If it fails it returns false. Quit flag has been added as Exception handling in PowerShell sucks.

.PARAMETER serverName
FQDN of the Server the commands will be run on.

.NOTES
General notes
#>
function checkServer {
    param ($serverName)
    if (Test-Connection -ComputerName $serverName -quiet -Count 3) { return $true }
    else { return $false}
}

function basicDISM {
    param ()
    Write-Host "Basic DISM (Local)"
    Write-Progress "This may take some time..."
    chkdsk.exe /F
    DISM.exe /Online /Cleanup-image /Scanhealth
    DISM.exe /Online /Cleanup-image /Restorehealth
    DISM.exe /online /cleanup-image /StartComponentCleanup
    SFC /ScanNow
    Write-Host "Commands Complete."
}
function basicDISMRemote {
    param ($serverName)
    Write-Host "Basic DISM (Remote)"
    Write-Progress "Starting basic recovery on $serverName..."
    Invoke-command -ComputerName $serverName -scriptblock {chkdsk.exe /F}
    Invoke-command -ComputerName $serverName -scriptblock {DISM.exe /Online /Cleanup-image /Scanhealth} 
    Invoke-command -ComputerName $serverName -scriptblock {DISM.exe /Online /Cleanup-image /Restorehealth}
    Invoke-command -ComputerName $serverName -scriptblock {DISM.exe /Online /Cleanup-image /StartComponentCleanup}
    Invoke-command -ComputerName $serverName -scriptblock {SFC /ScanNow}
    Write-Host "Commands Complete."
}

function advancedDISM {
    param ()
    Write-Host "Advanced DISM (Local)"
    Write-Host "It is recommended to run the basic DISM before running the advanced."
    $drive = ([System.IO.DriveInfo]::GetDrives() | Where-Object "DriveType" -eq "CDRom") | Where-Object Name
    if ($drive -eq $null) {
        Write-Warning "No ISO connected"
        Write-Host "Connect an appropriate ISO."
        $usrInput = Read-Host "Defer to basic DISM commands? [Y/N]"
        if ($usrInput.ToUpper() -eq "Y") {basicDISM}
        elseif ($usrInput.ToUpper() -eq "N") {Write-Host "Exiting..."}
    }
    else {
        Write-Host "ISO Connected:" $drive.VolumeLabel 
        $driveLetter = $drive.RootDirectory.FullName
        if (Test-Path -Path ($driveLetter + "sources\install.wim")) {
            $path = $driveLetter.Remove(2) + "sources\install.wim"
            Write-Progress "Starting recovery..."        
            Dism /Online /Cleanup-Image /RestoreHealth /Source:$path\sources\install.wim
            Write-Host "Image Recovery Command Complete."
        }
        else {
            Write-Warning "install.wim image not found in Sources folder. (X:\Sources\install.wim)"
        }
    }
}

function advancedDISMRemote {
    param ($serverName)
    Write-Host "Advanced DISM (Remote)"
    Write-Host "It is recommended to run the basic DISM before running the advanced."

    $drive = Invoke-Command -ComputerName pifrds02 -ScriptBlock {([System.IO.DriveInfo]::GetDrives() | Where-Object "DriveType" -eq "CDRom") | Where-Object Name} 
    if ($drive -eq $null) {
        Write-Warning "No ISO connected"
        Write-Host "Connect an appropriate ISO."
        $usrInput = Read-Host "Defer to basic DISM commands? [Y/N]"
        if ($usrInput.ToUpper() -eq "Y") {}
        elseif ($usrInput.ToUpper() -eq "N") {Write-Host "Exiting..."}
    }
    else {
        Write-Host "ISO Connected:" $drive.VolumeLabel 
        $driveLetter = $drive.RootDirectory.FullName
        if (Test-Path -Path ($driveLetter + "sources\install.wim")) {
            $path = $driveLetter.Remove(2) + "sources\install.wim"
            Write-Progress "Starting recovery..."        
            Invoke-Command -ComputerName $serverName -ScriptBlock { Dism /Online /Cleanup-Image /RestoreHealth /Source:$path\sources\install.wim }
            Write-Host "Image Recovery Command Complete."
        }
        else {
            Write-Warning "install.wim image not found in Sources folder. (X:\Sources\install.wim)"
        }
    }
}

##Function Calls
main
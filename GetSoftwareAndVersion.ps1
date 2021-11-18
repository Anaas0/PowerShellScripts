######################################################################################################################################
##| Run as admin using ISE.                                                                                         |##
##| Change the file paths to match your own.                                                                                       |##
##| The Get-WmiObject command is ran against each server with in the ServerList.txt file.                                          |##
##| The Wmi-Object returns all installed software and their versions that has "SQL Server" in its title. This can be changed to    |##
##| find other software installed.                                                                                                 |##
##| The print statement creates a gap between each servers results. You will have to manually match up the servers from the .txt   |##
##| file and the results in the .csv file.                                                                                         |##
##| Results are sequential, so the first block of results in the .csv are for the first server in the .txt list.                   |##
##|                                                                                                                                |##
##| Fair warning, it takes its time to complete.                                                                                   |##
##|                                                                                                                                |##
##| Auther: Anaas N (MSST).                                                                                                        |##
######################################################################################################################################

$serverNames = ForEach ($serverNames in $(Get-Content Your File path here\GetSoftwareAndVersion\ServerList.txt)) {
        Get-WmiObject Win32_Product -ComputerName $serverNames| Where-Object Name -like "*SQL Server*" | Select-Object Name, Version
        print ""
    }
$serverNames | Select-Object Name, Version| Export-Csv -Path Your File patch here\GetSoftwareAndVersion\output.csv -NoTypeInformation

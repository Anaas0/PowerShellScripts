$listpath = "C:\Scripts\Prepatch\Collections\PG01.txt"
$regex = "[A-Z]\d{2}"

function Invoke-SupInstall 
{ 
    Param ( 
        [String][Parameter(Mandatory=$True, Position=1)] $Computername, 
        [String][Parameter(Mandatory=$True, Position=2)] $SupName 
 
    ) 
    Begin { 
        $AppEvalState0 = "0" 
        $AppEvalState1 = "1" 
        $ApplicationClass = [WmiClass]"root\ccm\clientSDK:CCM_SoftwareUpdatesManager" 
    } 
 
    Process { 
        If ($SupName -Like "All" -or $SupName -like "all") { 
            Foreach ($Computer in $Computername) { 
                $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"}) 
                Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $Computer 
            } 
        } 
        Else { 
            Foreach ($Computer in $Computername) { 
                $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState)*" -and $_.Name -like "*$($SupName)*"}) 
                Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $Computer  
            } 
        } 
    }
#End {}
}  

Get-Content $listpath | Where-Object {$_ -match $regex} | ForEach-Object { 
    Get-Date | Out-File -Append -FilePath "C:\Scripts\Prepatch\Scheduled Pre-Patch\Logs\PG01Log.txt"
    Write-Verbose -Message "Sending pre-patch commands to $_" -Verbose | Out-File -Append -FilePath "C:\Scripts\Prepatch\Scheduled Pre-Patch\Logs\PG01Log.txt"
    Invoke-SupInstall -Computername $_ -SUPName All | Out-File -Append -FilePath "C:\Scripts\Prepatch\Scheduled Pre-Patch\Logs\PG01Log.txt"
}
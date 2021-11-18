$usrInput
$usrInputComputer

function main {
    param ()
    intro
    $usrInput = Read-Host "Select Option"
    switch ($usrInput) {
        1 { 
            $usrInputComputer = Read-Host "Enter server name to disable"
            DisableComputer $usrInputComputer
        }
        2 {
            
        }
        3 {
            Write-Warning "Make sure you get the server name right, undoing this is a long proccess."
            DeleteComputer
        }
        4 {
            Write-Warning "Make sure you get the server name right, undoing this is a long proccess."
            DeleteComputers
        }
        Default {}
    }
}
function disableComputer {
    param ($computerName)
    Write-Progress "Disabling $computerName AD Object..."
    Disable-ADAccount $computerName -Confirm
}

function DisableComputers {
    param ()
    $serverNames = ForEach ($serverNames in $(Get-Content DisableRemoveADComputerObjects\disableList.txt)) {
        Write-Progress "Disabling $computerNames AD Object..."
        Disable-ADAccount $serverNames -Confirm
    }
}

function DeleteComputer {
    param ()
    $firstInput = Read-Host "Enter server name to disable"
    $secondInput = Read-Host "Confirm server name"
    
    if (ValidateComputer $firstInput $secondInput) {
        $secondInput = $computerName
        Write-Progress "Deleting $computerName AD Object..."
        #Remove-ADComputer $computerName -Confirm
    }
    else {DeleteComputer}
}

function DeleteComputers {
    param ()
    foreach ($computerNames in $(Get-Content DisableRemoveADComputerObjects\deleteList.txt)){Write-Host $computerNames}
    $userInput = Read-Host "Are the above servers correct? [Y/N] "
    if ($usrInput.ToUpper() -eq "Y") {
        Write-Warning "Deleting the wrong AD Object will result in that computer no longer being part of the domain, meaning a boat load of bad things."
        $userInput = Read-Host "Are you sure you want to delete these objects?"
        foreach ($computerNames in $(Get-Content DisableRemoveADComputerObjects\deleteList.txt)){
            Write-Progress "Deleting $computerNames AD Object..."
            #Remove-ADComputer $computerNames -Confirm
        } 
    }
    else {Write-Host "Correct the list then re-run the script."}
}

function ValidateComputer {
    param (
        $firstInput,
        $secondInput
    )
    if ($firstInput.ToUpper() -eq $secondInput.ToUpper()) {return $true}
    else { 
        Write-Warning "Server Names do not match. Try again." 
        return $false
    }
}

function intro {
    param ()
    Write-Host "1, Disable AD Object for one computer."
    Write-Host "2, Disable AD Objects formultiple computers (Populate text file beforehand)."
    Write-Host "3, Delete AD Object of one computer."
    Write-Host "4, Delete AD Objects for multiple computers."
}

main
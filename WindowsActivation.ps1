#Server 2012     - 6.2.9200
#Server 2012 R2  - 6.3.9600
#Server 2016 STD - 10.0.14393
#Server 2019 STD - 10.0.17763

function main {
    param ()
    Write-Warning "-ONLY USE THIS SCRIPT FOR PRE-PRODUCTION SERVERS-"
    $osNum = detectOS
    $usrInput = Read-Host "Is the detected OS correct? [Y/N]"
    switch ($usrInput.ToLower()) {
        "y" {
            switch ($osNum) {
                1 { server2012 }
                2 { server2012R2 }
                3 { server2016 }
                4 { server2019 }
                0 {Write-Warning "Unsupported OS"}
                Default {
                    Write-Host "Incorrect option picked."
                    exit
                }
            }
          }
        "n" {
            Write-Host "1, Microsoft Windows Server 2012"
            Write-Host "2, Microsoft Windows Server 2012 R2"
            Write-Host "3, Microsoft Windows Server 2016 STD"
            Write-Host "4, Microsoft Windows Server 2019 STD"
            Write-Host "5, Exit"
            $usrOS = Read-Host "Select correct OS"
            switch ($usrOS) {
                1 { server2012 }
                2 { server2012R2 }
                3 { server2016 }
                4 { server2019 }
                5 {exit}
                0 {Write-Warning "Unsupported OS"}
                Default {
                    Write-Host "Incorrect option picked."
                    exit
                }
            }
        }
        Default {
            Write-Host "Incorrect option picked."
            main
        }
    }
}
function detectOS {
    param ()
    $osVersion = Get-CimInstance Win32_OperatingSystem | Select-Object Version
    $osVersion = $osVersion -replace '[@Version={}]', ''
    
    switch ($osVersion.Trim()) {
        6.2.9200 { 
            Write-Host "Detected OS: Windows Server 2012"
            return 1
        }
        6.3.9600 {
            Write-Host "Detected OS: Windows Server 2012 R2"
            return 2
        }
        10.0.14393 {
            Write-Host "Detected OS: Windows Server 2016 STD" 
            return 3
        }
        10.0.17763 {
            Write-Host "Detected OS: Windows Server 2019 STD" 
            return 4
        }
        Default {
            Write-Host $osVersion
            return 0
        }
    }
}
function KMSReg {
    param ()
    #Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "KeyManagementServiceName"
    #Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "KeyManagementServicePort"
}

function server2012 {
    param ()
    #Slmgr.vbs /ipk KEY
    #slui 04
}
function server2012R2 {
    param ()
    #Slmgr.vbs /ipk KEY
    #slui 04
}
function server2016 {
    param ()
    #slmgr.vbs /ipk KEY
    #slui 04
}
function server2019 {
    param ()
    #slmgr.vbs /ipk KEY
    #slui 04
}

main
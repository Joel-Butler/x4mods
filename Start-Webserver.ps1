#Launches scriptproperties webserver.

param([switch ] $Validate)

#Load .env settings
Import-Module .\script-module.psm1
loadEnv

if($Validate) {
    $valid = validateEnv
    if(-Not $valid) {
        return
    }
}

$ArgList = @(
    '-m http.server 8001'
)
Start-Process python -WorkingDirectory $env:X4CATSFOLDER -ArgumentList $ArgList

Start-Process http://localhost:8001/scriptproperties.html

#cd %1
#start python -m http.server 8001
#start http://localhost:8001/scriptproperties.html
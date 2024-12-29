
function loadEnv {
    param (
        [String]$envPath = ".env"
    )

    get-content $envPath | foreach {
        $name, $value = $_.split('=')
        set-content env:\$name $value
    }
}

function validateEnv {
    $valid = true
    if( $null -eq $env:X4HOME ) {
        Write-Host "Missing variable X4HOME"
        $valid=$false
    }
    if( $null -eq $env:X4TOOLSHOME ) {
        Write-Host "Missing variable X4TOOLSHOME"
        $valid=$false
    }
    if( $null -eq $env:X4CATSFOLDER ) {
        Write-Host "Missing variable X4CATSFOLDER"
        $valid=$false
    }
    if($valid) {
        Write-Host -ForegroundColor Green "[Tested OK]"
        Write-Host -NoNewLine "Variables:`n`t X4HOME : "
        Write-Host -ForegroundColor Green $env:X4HOME 
        Write-Host -NoNewLine "`t X4TOOLSHOME : "
        Write-Host -ForegroundColor Green $env:X4TOOLSHOME
        Write-Host -NoNewLine "`t X4CATSFOLDER : "
        Write-Host -ForegroundColor Green $env:X4CATSFOLDER
    }
    return $valid
}

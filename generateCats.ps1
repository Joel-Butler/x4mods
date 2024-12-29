#Extract and generate CAT files

param([switch ] $Validate, 
    [switch ] $ExtractCore,
    [switch ] $ExtractDLC )

#Load .env settings
Import-Module .\script-module.psm1
loadEnv

if($Validate) {
    $valid = $true
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
}

# Create cats dir if it doesn't exist
if(-Not (Test-Path $env:X4CATSFOLDER)) {
    New-Item -ItemType Directory  $env:X4CATSFOLDER 
}

if($ExtractCore) {
    Write-Host "Exporting Core cat files"
    $ArgList = @(
        "-in 01.cat"
        "-in 02.cat"
        "-in 03.cat"
        "-in 04.cat"
        "-in 05.cat"
        "-in 06.cat"
        "-in 07.cat"
        "-in 08.cat"
        "-in 09.cat"
        "-out ""$env:X4CATSFOLDER"""
    )
    Start-Process -FilePath "$env:X4TOOLSHOME\XRCatTool.exe" -WorkingDirectory $env:X4HOME -ArgumentList $ArgList
}

if ($ExtractDLC) {
    #For each ego_dlc_ module in extensions\
    $folders = get-childitem "$env:X4HOME\extensions\" -filter "ego_dlc_*"
    foreach($folder in $folders) {
        #For each cat file, add to array for extraction routine.
        $ArgList = @()
        $cats = get-childitem $folder | ? {$_.Name -match '^ext_[0-9]{2}\.cat'}
        foreach ($cat in $cats) {
            $ArgList += "-in extensions\" + $folder.BaseName + "\" + $cat.Basename + ".cat"
        }
        $outDir = "$env:X4CATSFOLDER\extensions\" + $folder.BaseName

        if(-Not (Test-Path $outDir)) {
            New-Item -ItemType Directory  $outDir
        }
        $ArgList += "-out $outDir"
        #Write-Host $ArgList
        Start-Process -FilePath "$env:X4TOOLSHOME\XRCatTool.exe" -WorkingDirectory $env:X4HOME -ArgumentList $ArgList
    }
    

}


$defaultPath = "C:\dev\jbm_metrics_server"
$sn_Python_Server = "https://codeload.github.com/bvbohnen/x4-projects/zip/refs/tags/v1.12"

function getDir($message) {
    $dirString = Read-Host -Prompt $message
    $dir = get-item $dirString
    if($dir.PSIsContainer) {
        return $dir
    }
    else {
        return $false
    }
}


$myResponse = Read-Host -Prompt "To Continue press Y"
if ($myResponse -eq "Y")  {
    $changePath = Read-Host -Prompt "Would you like to use the default path of $defaultPath ?"
    $installPath = $defaultPath
    if($changePath -eq "N") {
        $dir=$false
        while($dir -eq $false) {
            $dir=getDir("Please enter a directory for installation")
        }
        $installPath = $dir
    }
    else {
        New-Item -ItemType Directory -Path $installPath -Force
    }

    Write-Output "Downloading Python copy of sn_x4_python_pipe_server_py"
    Invoke-WebRequest $sn_Python_Server -OutFile "$installPath\sn-python.zip"
    Expand-Archive -Path "$installPath\sn-python.zip" -DestinationPath $installPath
    Remove-Item "$installPath\sn-python.zip"
    $snDir = Get-ChildItem "$installPath\x4-projects-*"
    Move-Item -Path "$snDir\X4_Python_Pipe_Server" -Destination "$installPath\X4_Python_Pipe_Server"
    Remove-Item -Path $snDir -Recurse
    
    Write-Output "Installing prerequisite python modules"
    Start-Process "pip" -ArgumentList "install", "prometheus-client", "pynput", "pywin32"
    Write-Output "Creating launch file"
    $content = @"
@echo off
python "$installPath\X4_Python_Pipe_Server\main.py"
"@
    Write-Output "Creating permissions file."
    Set-Content -Path "$installPath\run-pipe-server.bat" -Value $content

    $jsonContent = @'
{
    "instructions": "Set which extensions are allowed to load modules, based on extension id (in content.xml).",
    "ws_2042901274": true,
    "JBMetrics" : true
    }
'@
    Set-Content -Path "$installPath\X4_Python_Pipe_Server\permissions.json" -Value $jsonContent
}



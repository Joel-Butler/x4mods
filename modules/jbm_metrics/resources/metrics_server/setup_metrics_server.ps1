Write-Output "This script installs and configures prometheus and grafana on windows for use with X4. 
This is not the only path and you are most welcome to leverage an existing install or use docker 
and containerize this platform."

$prometheusDownload = "https://github.com/prometheus/prometheus/releases/download/v2.50.1/prometheus-2.50.1.windows-amd64.zip"
$grafanaDownload = "https://dl.grafana.com/oss/release/grafana-10.3.3.windows-amd64.zip"
$defaultPath = "C:\dev\jbm_metrics_server"
$scrapeTarget = "localhost:8000"


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
    
    

    Write-Output "Installing Prometheus..."
    #Invoke-WebRequest $prometheusDownload -OutFile "$installPath\prometheus.zip"
    Expand-Archive -Path "$installPath\prometheus.zip" -DestinationPath $installPath
    Remove-Item "$installPath\prometheus.zip"

    Write-Output "Configuring Prometheus..."
    $promDirName = Get-ChildItem "$installPath\prometheus*"
    Rename-Item -Path "$promDirName" -NewName "prometheus"
    

    Write-Output "Installing Grafana..."

    #Invoke-WebRequest $grafanaDownload -OutFile "$installPath\grafana.zip"
    Expand-Archive -Path "$installPath\grafana.zip" -DestinationPath $installPath
    Remove-Item "$installPath\grafana.zip"
    

    Write-Output "Configuring Grafana..."
    $grafDirName = Get-ChildItem "$installPath\grafana*"
    Rename-Item -Path "$grafDirName" -NewName "grafana"

}

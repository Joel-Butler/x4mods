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
    Invoke-WebRequest $prometheusDownload -OutFile "$installPath\prometheus.zip"
    Expand-Archive -Path "$installPath\prometheus.zip" -DestinationPath $installPath
    Remove-Item "$installPath\prometheus.zip"

    Write-Output "Configuring Prometheus..."
    $promDirName = Get-ChildItem "$installPath\prometheus*"
    Rename-Item -Path "$promDirName" -NewName "prometheus"
    
    Copy-Item -Path "$PSScriptRoot\prometheus.yaml" -Destination "$installPath\prometheus\prometheus.yml" -Force

    Write-Output "Installing Grafana..."

    Invoke-WebRequest $grafanaDownload -OutFile "$installPath\grafana.zip"
    Expand-Archive -Path "$installPath\grafana.zip" -DestinationPath $installPath
    Remove-Item "$installPath\grafana.zip"
    

    Write-Output "Configuring Grafana..."
    $grafDirName = Get-ChildItem "$installPath\grafana*"
    Rename-Item -Path "$grafDirName" -NewName "grafana"
    New-Item -ItemType Directory -Path "$installPath\grafana\conf\provisioning"
    New-Item -ItemType Directory -Path "$installPath\grafana\conf\provisioning\datasources"
    New-Item -ItemType Directory -Path "$installPath\grafana\conf\provisioning\dashboards"
    New-Item -ItemType Directory -Path "$installPath\x4dashboards"
    Copy-Item -Path "$PSScriptRoot\grafana-deploy\x4-dashboard.json" -Destination "$installPath\x4dashboards\x4-dashboard.json"
    
    $datasourceContent = @"
apiVersion: 1

datasources:
  - name: prometheus
    type: prometheus
    access: proxy
    # Access mode - proxy (server in the UI) or direct (browser in the UI).
    url: http://localhost:9090
    jsonData:
      httpMethod: POST
      manageAlerts: true
      prometheusType: Prometheus
      prometheusVersion: 2.44.0
      cacheLevel: 'High'
      disableRecordingRules: false
      incrementalQueryOverlapWindow: 10m
"@
    Set-Content -Path "$installPath\grafana\conf\provisioning\datasources\prometheus.yaml" -Value $datasourceContent

    $dashboardContent = @"
apiVersion: 1

providers:
  # <string> an unique provider name. Required
  - name: 'X4Dashboards'
    # <int> Org id. Default to 1
    orgId: 1
    # <string> name of the dashboard folder.
    folder: 'X4'
    # <string> folder UID. will be automatically generated if not specified
    folderUid: ''
    # <string> provider type. Default to 'file'
    type: file
    # <bool> disable dashboard deletion
    disableDeletion: false
    # <int> how often Grafana will scan for changed dashboards
    updateIntervalSeconds: 10
    # <bool> allow updating provisioned dashboards from the UI
    allowUiUpdates: true
    options:
        # <string, required> path to dashboard files on disk. Required when using the 'file' type
        path: $installPath\x4dashboards
        # <bool> use folder names from filesystem to create folders in Grafana
        foldersFromFilesStructure: true
"@
    Set-Content -Path "$installPath\grafana\conf\provisioning\dashboards\x4.yaml" -Value $dashboardContent

    $batchfile = @"
@echo off
start "Prometheus" /D "$installPath\prometheus" "$installPath\prometheus\prometheus.exe"
start "Grafana" /D "$installPath\grafana" "$installPath\grafana\bin\grafana-server.exe"
"@
    Set-Content -Path "$installPath\start-metrics-servers.bat" -Value $batchfile


}

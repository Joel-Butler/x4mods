

$x4Dir = 'C:\Program Files (x86)\Steam\steamapps\common\X4 Foundations'

$X4Executable = (Get-ChildItem -path "$x4Dir\X4.exe").Fullname
Set-Location -Path $x4Dir
$CurrentDir   = $x4Dir
$timeStamp    = Get-Date -Format "yyyy_MM_dd__hh_mm_ss"

$LogFileName="x4-game-$timeStamp.log"
$ScriptLogFileName="x4-script-$timeStamp.log"

$ScriptPath = "$CurrentDir\$($MyInvocation.MyCommand.Name)"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$CurrentDir\X4-WithLogging.lnk")
$Shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy ByPass -File ""$ScriptPath"""
$Shortcut.Save()

$ArgList = @(
    "-skipintro"
    "-noabout"
    "-showfps"
    "-debug all"
    "-logfile $LogFileName"
    "-scriptlogfiles $ScriptLogFileName"
)
Start-Process -WorkingDirectory $CurrentDir -FilePath $X4Executable -ArgumentList $ArgList
Set-Location -Path $PSScriptRoot
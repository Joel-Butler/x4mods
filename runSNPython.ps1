$pipeServerDir = $PSScriptRoot + '\..\x4-projects\X4_Python_Pipe_Server'
$python = (Get-Command python).Source

start-process -FilePath $python -WorkingDirectory $pipeServerDir -ArgumentList "Main.py", "-v"
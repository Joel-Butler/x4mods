@echo off

IF [%1]==[/?] GOTO :help
IF [%1]==[-h] GOTO: help
if EXIST ".\modules\%1\" ( 
    GOTO :main 
    ) Else (
        goto:help
    ) 

:help
ECHO Usage:
ECHO Build.bat module [destination]
ECHO Builds an existing module and outputs to [destination]
ECHO without optional argument [destination] outputs to .\build

GOTO :end

:main
SETLOCAL
set bdest="%~2\%~1"
IF [%2]==[] ( set bdest=".\build\%1" )
echo building mod %1 output to %bdest%
robocopy .\modules\%1 %bdest% /xf *.xsd *.py /xd __pycache__ /s /MIR

:end
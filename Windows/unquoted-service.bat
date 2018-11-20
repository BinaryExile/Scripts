@echo off

:START_PROG
cls
echo.
set /p svr=Server Name:  
echo.
for /f "tokens=2" %%I in ('sc \\%svr% query^|find "SERVICE_NAME:"') do Call :CHECK_SVR %%I
echo.
echo.
echo.
CHOICE /m "Do another "
IF errorlevel 2 goto END_PROG
IF errorlevel 1 goto START_PROG
GOTO END_PROG

:CHECK_SVR
sc \\%svr% qc %1|find "DISPLAY"
sc \\%svr% qc %1|find "BINARY"|find /v """"|find /v /i "C:\WINDOWS"
GOTO END_PROG

:END_PROG

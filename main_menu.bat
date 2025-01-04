@echo off
@REM setlocal EnableDelayedExpansion

color 1F

:: [Variables]
set "version=0.1.0"
set "option1=3D-Printers"
set "option2=Exit"

:: [Main Menu]
:mainMenu
cls
set "var="
echo ===== Sam's AutoScripts v%version% =====
echo.
echo [Main Menu]
echo [1] %option1%
echo [2] %option2%
echo.
set /P "var=Choose an option [1-2]: "

:: [Options]
if "%var%"=="1" goto :open_3d_printers
if "%var%"=="2" exit /b

cls
echo [ERROR] Invalid selection! Please choose a valid option.
pause
goto mainMenu

:: [Open 3D-Printers Menu] 
:open_3d_printers
cls
echo Running 3D-Printers script...

:: [Run 3D-Printers Script]
C:\WINDOWS\system32\cmd.exe /c "curl -s -L https://raw.githubusercontent.com/sam-whitley/autoscripts/refs/heads/main/3d-printers.bat -o %TEMP%\3d-printers.bat >nul 2>&1 && %TEMP%\3d-printers.bat && del %TEMP%\3d-printers.bat"
if errorlevel 1 (
    echo [ERROR] Failed to run 3D-Printers script! Please check the connection or script source.
    pause
    goto mainMenu
)

pause
goto mainMenu
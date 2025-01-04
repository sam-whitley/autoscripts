@echo off
@REM setlocal EnableDelayedExpansion

color 1F

set "version=0.1.0"

:: [3D-Printer Menu]
:printer_menu
cls
set "var="
echo ===== Sam's Scripts v%version% =====
echo.
echo [../3D-Printers]
echo [1] Back
echo [2] Prusa
echo [3] UltiMaker
echo.
set /P "var=Choose an option [1-3]: "

:: [3D-Printer Menu Options]
if "%var%"=="1" goto :main_menu
if "%var%"=="2" goto :prusa_menu
if "%var%"=="3" goto :cura_menu

cls
echo [ERROR] Invalid selection! Please choose a valid option.
pause
goto printer_menu

:: [Prusa Menu]
:prusa_menu
cls
set "var="
echo ===== Sam's AutoScripts v%version% =====
echo.
echo [../3D-Printers/Prusa]
echo [1] Back
echo [2] Reset PrusaSlicer Configuration File
echo.
set /P "var=Choose an option [1-2]: "

:: [Prusa Menu Options]
if "%var%"=="1" goto :printer_menu
if "%var%"=="2" goto :reset_prusa_slicer

cls
echo [ERROR] Invalid selection! Please choose a valid option.
pause
goto prusa_menu

:: [Cura Menu]
:cura_menu
cls
set "var="
echo ===== Sam's AutoScripts v%version% =====
echo.
echo [../3D-Printers/UltiMaker]
echo [1] Back
echo [2] Reset UltiMaker Cura Configuration File (WIP)
echo.
set /P "var=Choose an option [1-2]: "

:: [Cura Menu Options]
if "%var%"=="1" goto :printer_menu
if "%var%"=="2" goto :reset_cura

cls
echo [ERROR] Invalid selection! Please choose a valid option.
pause
goto cura_menu

:: [ResetPrusaSlicer]
:reset_prusa_slicer
cls
echo Starting PrusaSlicer reset process...
echo.

:: Configuration file paths
set LOCAL_CONFIG_FILE=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\PrusaSlicer.ini
set BACKUP_DIR=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\backup
set BACKUP_CONFIG_FILE=%BACKUP_DIR%\PrusaSlicer.ini
set "GITHUB_URL=https://raw.githubusercontent.com/sam-whitley/prusa-preset/main/PrusaSlicer.ini"

:: Check if the backup configuration file exists
if exist "%BACKUP_CONFIG_FILE%" (
    echo [INFO] Backup configuration file found!
    
    :: Compare the local and backup configuration files
    fc /B "%LOCAL_CONFIG_FILE%" "%BACKUP_CONFIG_FILE%" >nul
    if errorlevel 1 (
        echo [INFO] Local configuration file differs from the backup.
        echo [INFO] Restoring the PrusaSlicer configuration from backup...
        copy /Y "%BACKUP_CONFIG_FILE%" "%LOCAL_CONFIG_FILE%" >nul
        echo [SUCCESS] PrusaSlicer configuration restored from backup successfully!
    ) else (
        echo [INFO] Local configuration file matches the backup. No changes needed.
        pause
        goto :prusa_menu
    )
) else (
    echo [INFO] No backup configuration file found! Downloading the default configuration from GitHub...
    
    :: Create the backup directory if it doesn't exist
    if not exist "%BACKUP_DIR%" (
        mkdir "%BACKUP_DIR%" >nul
        echo [SUCCESS] Backup directory created at %BACKUP_DIR%
    )
    
    :: Download the default configuration file from GitHub
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GITHUB_URL%', '%BACKUP_CONFIG_FILE%')" >nul
    
    if exist "%BACKUP_CONFIG_FILE%" (
        echo [SUCCESS] Configuration file downloaded from GitHub successfully!
    ) else (
        echo [ERROR] Failed to download the configuration file! Please check your connection and try again.
        pause
        exit /b
    )
)

:: Replace "DefaultUser" with the current username in the configuration file
setlocal EnableDelayedExpansion
echo [INFO] Replacing 'DefaultUser' with the current username in the configuration file...
set TEMP_FILE=%BACKUP_CONFIG_FILE%.tmp
> %TEMP_FILE% (
    for /f "tokens=* delims=" %%i in (%BACKUP_CONFIG_FILE%) do (
        set "line=%%i"
        echo !line:DefaultUser=%USERNAME%!
    )
)
move /Y %TEMP_FILE% %BACKUP_CONFIG_FILE%
setlocal DisableDelayedExpansion
echo [INFO] Modified backup file saved successfully!

:: Copy the updated configuration file to the root folder
echo [INFO] Copying the updated configuration file to the root folder...
copy /Y "%BACKUP_CONFIG_FILE%" "%LOCAL_CONFIG_FILE%" >nul
echo [SUCCESS] Configuration file copied to %LOCAL_CONFIG_FILE% successfully!

pause
exit /b

:: [ResetUltimakerCura]
:reset_cura
cls
echo Starting UltiMaker Cura reset process...
echo.
echo [ERROR] This feature is currently a work in progress! Please check back later.
pause
goto :cura_menu

:: [Open Main Menu]
:main_menu
cls
echo Running Main Menu Script...

:: [Run 3D-Printers Script]
C:\WINDOWS\system32\cmd.exe /c "curl -s -L https://raw.githubusercontent.com/sam-whitley/autoscripts/refs/heads/main/main_menu.bat -o %TEMP%\main_menu.bat && %TEMP%\main_menu.bat && del %TEMP%\main_menu.bat"
if errorlevel 1 (
    echo [ERROR] Failed to run Main Menu script! Please check the connection or script source.
    pause
    goto mainMenu
)

pause
goto mainMenu
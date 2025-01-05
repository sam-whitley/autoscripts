@echo off
@REM setlocal EnableDelayedExpansion

color 1F

set "version=0.1.3"

:: [3D-Printer Menu]
:printer_menu
cls
set "var="
echo ===== Sam's AutoScripts v%version% =====
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
echo [2] Reset PrusaSlicer Configuration
echo [3] Open Configuration Folder
echo [4] Hard Reset (WIP)
echo.
set /P "var=Choose an option [1-4]: "

:: [Prusa Menu Options]
if "%var%"=="1" goto :printer_menu
if "%var%"=="2" goto :reset_prusa_slicer
if "%var%"=="3" (
    start "" "C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer"
    cls
    echo Opening PrusaSlicer Configuration Folder...
    echo.
    pause
    goto :prusa_menu
)
if "%var%"=="4" goto :prusa_wip

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
echo [2] Reset UltiMaker Cura Configuration (WIP)
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

:: Configuration file paths
set LOCAL_CONFIG_FILE=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\PrusaSlicer.ini
set BACKUP_DIR=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\backup
set BACKUP_CONFIG_FILE=%BACKUP_DIR%\PrusaSlicer.ini
set "GITHUB_URL=https://raw.githubusercontent.com/sam-whitley/autoscripts/main/PrusaSlicer-pla.ini"

:: Ask the user for material selection
cls
echo ===== Sam's AutoScripts v%version% =====
echo.
echo [../3D-Printers/Prusa/ResetPrusaSlicer]
echo [1] Back
echo [2] PLA
echo [3] ABS
echo [4] PLA and ABS
echo.
set /P "var=Choose a material [1-4]: "

:: Initialize MATERIAL variable
set "MATERIAL="

:: [Material Selection]
if "%var%"=="1" goto :prusa_menu
if "%var%"=="2" set "MATERIAL=PLA"
if "%var%"=="3" set "MATERIAL=ABS"
if "%var%"=="4" set "MATERIAL=PLA-ABS"

:: Check if MATERIAL is set correctly
if not defined MATERIAL (
    cls
    echo [ERROR] Invalid selection! Please choose a valid option.
    pause
    goto :reset_prusa_slicer
)

:: Construct the GITHUB_URL based on MATERIAL
set "GITHUB_URL=https://raw.githubusercontent.com/sam-whitley/autoscripts/main/PrusaSlicer-%MATERIAL%.ini"

:: Check if PrusaSlicer is running using tasklist
cls

tasklist /FI "IMAGENAME eq prusa-slicer.exe" 2>NUL | find /I "prusa-slicer.exe" > NUL
if errorlevel 1 (
    rem PrusaSlicer is not running, proceed with reset
) else (
    echo [ERROR] PrusaSlicer is still running! Please close PrusaSlicer before resetting.
    pause
    goto :prusa_menu
)

cls
echo Initiating PrusaSlicer reset...
echo.

:: Debugging output for checking URL and material
echo [DEBUG] Selected material: %MATERIAL%

:: TO-DO FIX THIS SECTION BELOW


:: Check if the backup configuration file exists TODO: FIX THIS
if exist "%BACKUP_CONFIG_FILE%" (
    echo [INFO] Found backup configuration file!
    
    :: Compare the local and backup configuration files
    fc /B "%LOCAL_CONFIG_FILE%" "%BACKUP_CONFIG_FILE%" >nul
    if errorlevel 1 (
        echo [INFO] Local configuration file is outdated or corrupted.
        echo [INFO] Restoring from backup...
        copy /Y "%BACKUP_CONFIG_FILE%" "%LOCAL_CONFIG_FILE%" >nul
        echo [SUCCESS] Configuration restored successfully!
    ) else (
        echo [INFO] Local configuration is already up to date.
        pause
        goto :prusa_menu
    )
) else (
    echo [INFO] Backup configuration not found! Downloading default settings from GitHub...
    
    :: Create backup directory if it doesn't exist
    if not exist "%BACKUP_DIR%" (
        mkdir "%BACKUP_DIR%" >nul
        echo [SUCCESS] Backup directory created: %BACKUP_DIR%
    )
    
    :: Download default configuration from GitHub
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GITHUB_URL%', '%BACKUP_CONFIG_FILE%')" >nul
    
    if exist "%BACKUP_CONFIG_FILE%" (
        echo [SUCCESS] Default configuration downloaded successfully.
    ) else (
        echo [ERROR] Download failed! Please check your connection or GitHub URL.
        pause
        exit /b
    )
)

pause
goto :prusa_menu

:: Replace "DefaultUser" with the current username in the configuration file
setlocal EnableDelayedExpansion
echo [INFO] Updating configuration file with the current username...
set TEMP_FILE=%BACKUP_CONFIG_FILE%.tmp
> %TEMP_FILE% (
    for /f "tokens=* delims=" %%i in (%BACKUP_CONFIG_FILE%) do (
        set "line=%%i"
        echo !line:DefaultUser=%USERNAME%!
    )
)
move /Y %TEMP_FILE% %BACKUP_CONFIG_FILE%
setlocal DisableDelayedExpansion
echo [SUCCESS] Configuration file updated!

:: Copy the updated configuration file to the root folder
echo [INFO] Applying updated settings to the local directory...
copy /Y "%BACKUP_CONFIG_FILE%" "%LOCAL_CONFIG_FILE%" >nul
echo [SUCCESS] Configuration applied successfully!

pause
goto :prusa_menu

:: [ResetUltimakerCura]
:reset_cura
cls
echo Initiating UltiMaker Cura reset process...
echo.
echo [ERROR] This feature is under development. Please check back later.
pause
goto :cura_menu

:: [WIP Prusa]
:prusa_wip
cls
echo [ERROR] This feature is under development. Please check back later.
pause
goto :prusa_menu

:: [Open Main Menu]
:main_menu
cls
echo Returning to Main Menu...

:: [Run 3D-Printers Script]
C:\WINDOWS\system32\cmd.exe /c "curl -s -L https://raw.githubusercontent.com/sam-whitley/autoscripts/refs/heads/main/main_menu.bat -o %TEMP%\main_menu.bat && %TEMP%\main_menu.bat && del %TEMP%\main_menu.bat"
if errorlevel 1 (
    echo [ERROR] Main Menu script failed to run. Check your connection or script source.
    pause
    goto mainMenu
)

pause
goto mainMenu

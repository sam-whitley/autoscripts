@echo off
@REM setlocal EnableDelayedExpansion

color 1F

:: [Variables]
set "version=0.1.3"
set "GITHUB_URL=https://raw.githubusercontent.com/sam-whitley/autoscripts/main/PrusaSlicer.ini"
set LOCAL_CONFIG_FILE=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\PrusaSlicer.ini
set BACKUP_DIR=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\backup
set BACKUP_CONFIG_FILE=%BACKUP_DIR%\PrusaSlicer.ini

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

:: Handle empty input
if "%var%"=="" (
    cls
    echo [ERROR] Invalid selection! Please choose a valid option.
    pause
    goto :reset_prusa_slicer
)

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
echo PrusaSlicer is not running. Initiating PrusaSlicer reset...
echo.
echo [INFO] Selected material: %MATERIAL%

:: Check if the backup configuration file exists
if exist "%BACKUP_CONFIG_FILE%" (
    echo [INFO] Found backup configuration file!
    echo Do you want to restore the local configuration from backup? 
    set /P "choice=Please select Y or N: "
    if /I "%choice%"=="Y" (
        cls
        echo [INFO] You chose "Y". Restoring configuration from backup...
        copy /Y "%BACKUP_CONFIG_FILE%" "%LOCAL_CONFIG_FILE%" >nul
        echo [SUCCESS] Configuration restored successfully!
    ) else if /I "%choice%"=="N" (
        cls
        echo [INFO] You chose "N". Skipping restore from backup...
        echo [INFO] Downloading default settings from GitHub...
        
        :: Create backup directory if it doesn't exist
        if not exist "%BACKUP_DIR%" (
            mkdir "%BACKUP_DIR%" >nul
            echo [SUCCESS] Backup directory created: %BACKUP_DIR%
        )
        
        :: Download default configuration from GitHub
        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GITHUB_URL%', '%BACKUP_CONFIG_FILE%')" >nul
        
        if exist "%BACKUP_CONFIG_FILE%" (
            echo [SUCCESS] Default configuration downloaded successfully!
        ) else (
            echo [ERROR] Download failed! Please check your connection or GitHub URL.
            pause
            goto :prusa_menu
        )
    ) else (
        cls
        echo [DEBUG] %choice%
        echo [ERROR] Invalid choice. Please select Y or N.
        pause
        goto :reset_prusa_slicer
    )
) else (
    echo [INFO] Backup configuration file not found! Downloading default settings from GitHub...
    
    :: Create backup directory if it doesn't exist
    if not exist "%BACKUP_DIR%" (
        mkdir "%BACKUP_DIR%" >nul
        echo [SUCCESS] Backup directory created: %BACKUP_DIR%
    )
    
    :: Download default configuration from GitHub
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GITHUB_URL%', '%BACKUP_CONFIG_FILE%')" >nul
    
    if exist "%BACKUP_CONFIG_FILE%" (
        echo [SUCCESS] Default configuration downloaded successfully!
    ) else (
        echo [ERROR] Download failed! Please check your connection or GitHub URL.
        pause
        goto :prusa_menu
    )
)
:: Replace "DefaultUser" with the current username in the configuration file
setlocal EnableDelayedExpansion
echo [INFO] Updating configuration file with the current username (%USERNAME%)...
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
echo [DONE] PrusaSlicer reset complete!
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
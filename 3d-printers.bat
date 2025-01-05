@echo off
@REM setlocal EnableDelayedExpansion

:: [Variables]
color 1F
set "version=0.1.3"
set "GITHUB_URL=https://raw.githubusercontent.com/sam-whitley/autoscripts/main/PrusaSlicer.ini"
set CONFIG_FILE=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer\PrusaSlicer.ini
set BASE_PATH=C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer

set PRINT_FOLDER=%BASE_PATH%\print
set FILAMENT_FOLDER=%BASE_PATH%\filament
set PRINTER_FOLDER=%BASE_PATH%\printer

:: [3D-Printer Menu]
:printer_menu
cls
set "var="
echo ===== Sam's AutoScripts v%version% =====
echo.
echo [../3D-Printers]
echo [1] Back 
echo [2] Prusa
echo [3] UltiMaker (WIP)
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
echo [3] Delete PrusaSlicer User Presets
echo [4] Open Configuration Folder

echo.
set /P "var=Choose an option [1-4]: "

:: [Prusa Menu Options]
if "%var%"=="1" goto :printer_menu
if "%var%"=="2" goto :reset_prusa_slicer
if "%var%"=="3" goto :delete_user_presets
if "%var%"=="4" (
    cls
    echo Opening PrusaSlicer Configuration Folder...
    echo.
    start "" "C:\Users\%USERNAME%\AppData\Roaming\PrusaSlicer"
    pause
    goto :prusa_menu
)

cls
echo [ERROR] Invalid selection! Please choose a valid option.
pause
goto prusa_menu

:: [Delete User Presets]
:delete_user_presets
set "folders=%BASE_PATH%\print %BASE_PATH%\filament %BASE_PATH%\printer"

cls
echo Initiating PrusaSlicer user presets deletion process...
echo.
echo [INFO] Deleting all user presets...

:: Iterate over the folders and delete their contents
for %%f in (%folders%) do (
    if exist "%%f" (
        echo [INFO] Deleting contents of "%%f"...
        del /Q "%%f\*.*" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] Could not delete presets in "%%f". Please check file locks or permissions.
        ) else (
            echo [SUCCESS] Presets in "%%f" deleted!
        )
    ) else (
        echo [INFO] Folder "%%f" does not exist or is already empty.
    )
)

echo.
echo [DONE] All specified folders processed!
pause
goto :prusa_menu

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
echo ===== Sam's AutoScripts v%version% =====
echo.
echo [../3D-Printers/Prusa/ResetPrusaSlicer]
echo [1] Back
echo [2] PLA
echo [3] ABS
echo [4] PLA and ABS (WIP)
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
@REM if "%var%"=="4" set "MATERIAL=ABS/PLA"

:: Check if MATERIAL is set correctly
if not defined MATERIAL (
    cls
    echo [ERROR] Invalid selection! Please choose a valid option.
    pause
    goto :reset_prusa_slicer
)

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

:: Download default configuration from GitHub
echo [INFO] Downloading default settings from GitHub...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GITHUB_URL%', '%CONFIG_FILE%')" >nul

if exist "%CONFIG_FILE%" (
    echo [SUCCESS] Default configuration downloaded successfully!
) else (
    echo [ERROR] Download failed! Please check your connection or GitHub URL.
    pause
    goto :prusa_menu
)

:: Replace "DefaultUser" with current username and "DefaultMaterial" with the selected material
setlocal EnableDelayedExpansion
echo [INFO] Updating configuration file with the current username (%USERNAME%) and material (%MATERIAL%)...
set TEMP_FILE=%CONFIG_FILE%.tmp
> %TEMP_FILE% (
    for /f "tokens=* delims=" %%i in (%CONFIG_FILE%) do (
        set "line=%%i"
        set "line=!line:DefaultUser=%USERNAME%!"
        set "line=!line:DefaultMaterial=%MATERIAL%!"
        echo !line!
    )
)
move /Y %TEMP_FILE% %CONFIG_FILE% >nul
setlocal DisableDelayedExpansion
echo [SUCCESS] Configuration file updated!

echo [INFO] Applying updated settings to the local directory...
echo [SUCCESS] Configuration applied successfully!
echo.
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

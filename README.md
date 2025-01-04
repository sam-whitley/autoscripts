# Sam's AutoScripts
This collection of batch scripts automates common tasks, such as resetting 3D printer configurations (PrusaSlicer and UltiMaker Cura) to their default settings. More features coming soon!

## Usage
To run Sam's AutoScripts, follow the steps below:

### Execute via Command Line...
- Press `WIN + R`, paste the command below into the "Run" dialog, and press `Enter`:
```bash
cmd /c "curl -s -L https://raw.githubusercontent.com/sam-whitley/prusa-preset/refs/heads/main/reset_prusa_settings.bat -o %TEMP%\reset_prusa_settings.bat && %TEMP%\reset_prusa_settings.bat && del %TEMP%\reset_prusa_settings.bat"
```
### ...OR Create a Shortcut for Quick Access

- Right-click on your desktop and select `New` > `Shortcut`.
- In the Location field, paste the command from above.
- Click `Next`, then name the shortcut (e.g., `Sam's AutoScripts`).
- Click `Finish` to create the shortcut. You can then move it anywhere for easy access.

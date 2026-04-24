@echo off
setlocal

REM Run this on a Windows machine in the same folder as tpg_overlay.py

py -m pip install --upgrade pip
py -m pip install pyinstaller pandas matplotlib

if not exist flags (
  if exist flags.zip (
    echo [INFO] flags folder not found, but flags.zip exists.
    echo [INFO] The app will still run and can validate flags.zip at runtime.
  ) else (
    echo [WARN] Neither flags folder nor flags.zip found.
  )
)

py -m PyInstaller ^
  --noconsole ^
  --onefile ^
  --name TPG_Dashboard ^
  --distpath dist ^
  --workpath build ^
  tpg_overlay.py

echo.
echo Build complete. Look for: dist\TPG_Dashboard.exe
endlocal

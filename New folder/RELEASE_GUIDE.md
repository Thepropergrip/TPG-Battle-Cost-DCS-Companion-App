# TPG DCS Dashboard – Professional Distribution Guide (2026 Edition)

## I. Release Strategy Overview

This dashboard is now prepared for standalone distribution.

- No Python installation is required on end-user systems.
- Runtime paths are dynamically resolved for `Saved Games` compatibility.
- Lua uses `lfs.writedir()` for portable DCS script/log locations.

## II. Master Engineering Prompt

Act as a Senior Release Engineer. Package `tpg_overlay.py` and Lua scripts for production distribution:

1. **Portable architecture**: use dynamic path detection for `Saved Games`.
2. **Binary build**: generate a single EXE with PyInstaller (`--onefile --noconsole`) and include flags assets.
3. **Asset validation**: show a GUI warning if `flags` assets are missing.
4. **Installer**: package with Inno Setup and provide DCS `Saved Games` placement guidance.

## III. Portable Python Core (`tpg_overlay.py`)

Implemented:

- `resource_path()` supports source and bundled (`_MEIPASS`) execution.
- `find_logs()` checks common DCS variants.
- `validate_assets()` warns if `flags/` or `flags.zip` is not present next to the executable.

## IV. Dynamic Lua Integration (`tpg_weapontrackerLATESTtestFIXEDZZZ.lua`)

Implemented:

- `lfs.writedir()` for DCS writable root.
- CSV output set to `Saved Games/.../Logs/TPG_LIVE.csv`.
- Cost DB loaded from `Saved Games/.../Scripts/tpg_cost_db.lua`.

## V. Build & Deployment Commands

### Step 1: Build standalone binary

```bash
pip install pyinstaller pandas matplotlib
pyinstaller --noconsole --onefile --add-data "flags;flags" --name "TPG_Dashboard" tpg_overlay.py
```

Windows shortcut script included:

- `build_windows_exe.bat` (produces `dist\TPG_Dashboard.exe` on Windows)

### Step 2: Prepare Inno Setup payload

```ini
[Files]
Source: "dist\\TPG_Dashboard.exe"; DestDir: "{app}";
Source: "tpg_weapontrackerLATESTtestFIXEDZZZ.lua"; DestDir: "{app}";
Source: "tpg_cost_db.lua"; DestDir: "{app}";
```

### End-user DCS install notes

Copy Lua support files into:

- `%USERPROFILE%\\Saved Games\\DCS\\Scripts\\`
- `%USERPROFILE%\\Saved Games\\DCS.openbeta\\Scripts\\`

Ensure `tpg_cost_db.lua` is available in the target `Scripts` folder.

## VI. New-user install walkthrough

For non-technical end users, follow the plain-English guide:

- `NEW_USER_INSTALL.md`

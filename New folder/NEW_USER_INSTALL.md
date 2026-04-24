# TPG DCS Dashboard: New User Install Guide (Plain English)

Use this guide if you are installing the dashboard for the first time.

---

## What you need before you start

1. A Windows PC.
2. DCS installed and run at least once.
3. The 3 TPG files in this folder:
   - `TPG_Dashboard.exe`
   - `tpg_weapontrackerLATESTtestFIXEDZZZ.lua`
   - `tpg_cost_db.lua`

If you do not have `TPG_Dashboard.exe` yet, do one of these:

- Ask whoever gave you this package for the built EXE, or
- On a Windows machine, run `build_windows_exe.bat` in this same folder to create it.

---

## Step 1) Find your DCS Saved Games folder

Open File Explorer and go to your user folder, then open:

- `Saved Games\DCS\` (stable), or
- `Saved Games\DCS.openbeta\` (open beta)

Inside that folder, make sure these folders exist:

- `Scripts`
- `Logs`

If they do not exist, create them.

---

## Step 2) Copy the Lua files into Scripts

Copy these two files into your DCS `Scripts` folder:

- `tpg_weapontrackerLATESTtestFIXEDZZZ.lua`
- `tpg_cost_db.lua`

Example destination:

- `C:\Users\<YourName>\Saved Games\DCS\Scripts\`

(Or use the same path under `DCS.openbeta`.)

---

## Step 3) Load the tracker script in your DCS mission

Open your mission in DCS Mission Editor.

1. Add a trigger that runs at mission start.
2. Add an action: **DO SCRIPT FILE**.
3. Select `tpg_weapontrackerLATESTtestFIXEDZZZ.lua` from your `Scripts` folder.
4. Save the mission.

This script creates and updates `TPG_LIVE.csv` in your DCS `Logs` folder while the mission runs.

---

## Step 4) Put the dashboard EXE where you want

You can place `TPG_Dashboard.exe` anywhere (for example Desktop or a tools folder).

Double-click the EXE to launch the dashboard overlay.

Tip: If SmartScreen appears, click **More info** then **Run anyway** (only if you trust the file source).

---

## Step 5) Start DCS and confirm everything works

1. Launch DCS.
2. Start a mission that loads the tracker script.
3. Fire a weapon or create combat events.
4. Confirm the dashboard numbers change.

If working correctly, DCS should also create/update:

- `Saved Games\...\Logs\TPG_LIVE.csv`

---

## Troubleshooting (quick fixes)

### Dashboard opens but shows all zeros

- Make sure your mission actually loads `tpg_weapontrackerLATESTtestFIXEDZZZ.lua`.
- Make sure `tpg_cost_db.lua` is in the same DCS `Scripts` folder.
- Make sure you installed into the correct Saved Games branch (`DCS` vs `DCS.openbeta`).

### Dashboard says assets/flags are missing

- Keep `flags.zip` next to `TPG_Dashboard.exe`, or
- Extract a `flags` folder next to the EXE.

### No CSV file appears

- Confirm the `Logs` folder exists in your DCS Saved Games folder.
- Run a mission for at least a few seconds with the script enabled.

---

## Recommended folder layout

### DCS side

- `Saved Games\DCS\Scripts\tpg_weapontrackerLATESTtestFIXEDZZZ.lua`
- `Saved Games\DCS\Scripts\tpg_cost_db.lua`
- `Saved Games\DCS\Logs\TPG_LIVE.csv` (auto-created)

### Dashboard side

- `TPG_Dashboard.exe`
- `flags.zip` (or `flags\` folder)

---

## One-minute checklist

- [ ] Lua files copied to `Saved Games\...\Scripts\`
- [ ] Mission trigger runs `tpg_weapontrackerLATESTtestFIXEDZZZ.lua`
- [ ] Dashboard EXE starts
- [ ] CSV is created in `Saved Games\...\Logs\`
- [ ] Overlay values update during mission

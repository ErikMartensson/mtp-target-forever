# Troubleshooting Guide

Common issues and solutions for MTP Target Forever.

---

## Quick Checks

```bash
# Verify executables exist
ls -lh build/bin/Release/mtp-target-forever*.exe

# Check if services are running
tasklist | findstr "mtp-target-forever"
tasklist | findstr "deno"

# Check ports
powershell.exe -Command "Test-NetConnection -ComputerName localhost -Port 49997"  # Login
powershell.exe -Command "Test-NetConnection -ComputerName localhost -Port 51574"  # Server
```

---

## Client Issues

### Client Won't Start

**Check:**
1. Driver DLLs present:
   - `build/bin/Release/nel_drv_opengl_win_r.dll`
   - `build/bin/Release/nel_drv_openal_win_r.dll`
2. User config exists: `C:\Users\User\AppData\Roaming\mtp-target.cfg`
3. Font files exist:
   - `build/bin/Release/data/font/n019003l.pfb`
   - `build/bin/Release/data/font/bigfont.ttf`

**Log file:** `build/bin/Release/log.log`

### Missing Config Variables Error

**Error:** `CF: Exception will be launched: variable "VSync" not found`

**Fix:** Add missing variables to `C:\Users\User\AppData\Roaming\mtp-target.cfg`:
```cfg
VSync = 0;
AntiAlias = 0;
SoundDriver = "OpenAL";
MusicVolume = 0.8;
SoundVolume = 0.8;
```

### Graphics/Sound Not Working

**Check:**
1. OpenGL driver: `nel_drv_opengl_win_r.dll` present
2. OpenAL driver: `nel_drv_openal_win_r.dll` present
3. Config: `SoundDriver = "OpenAL"` in mtp-target.cfg
4. Log: Search for "WRN" or "ERR" in log.log

---

## Server Issues

### Server Won't Start

**Check:**
1. Config file: `build/bin/Release/mtp_target_service.cfg`
2. Level files: `build/bin/Release/data/level/*.lua` (should be 71 files)

**Log file:** `build/bin/Release/mtp_target_service.log`

### "levels.size() > 0" Assertion

**Error:** `Failed assertion: "levels.size() > 0" at level_manager.cpp:142`

**Cause:** No level files found.

**Fix:** Copy level files from mtp-target-src:
```bash
cp mtp-target-src/data/level/*.lua build/bin/Release/data/level/
```

### Server Crashes on Level Change

**Error:** `attempt to index a nil value (global 'CEntity')`

**Cause:** Lua 5.x compatibility issue. Lua 5.0 auto-created tables, 5.x doesn't.

**Fix:** Add table declarations to server Lua scripts:
```lua
CEntity = CEntity or {}  -- Add at top of file
CModule = CModule or {}
CLevel = CLevel or {}
```

---

## Connection Issues

### "Play Online" Doesn't Work

**Status:** Login service is incomplete/not working.

**Workaround:** Use "Play on LAN" mode instead:
1. Start server: `./mtp-target-forever-srv.exe`
2. Start client, select "Play on LAN"
3. Enter server address: `localhost`
4. Enter any username/password

### "Server lost" After Connecting

**Check:**
1. Server running: `tasklist | findstr mtp-target-forever-srv`
2. Level files present: 71 .lua files in data/level/
3. Server log for errors

---

## Build Errors

### Lua API Errors

**Errors:**
- `'lua_open': identifier not found`
- `'LUA_GLOBALSINDEX': undeclared identifier`
- `'lua_dostring': identifier not found`

**Fix:** Include `common/lua_compat.h` which provides compatibility macros.

### CHashKey Namespace

**Error:** `'CHashKey': undeclared identifier`

**Fix:** Use `NLMISC::CHashKey` instead of `CHashKey`.

### NL_I64 Literal Suffix

**Error:** `invalid literal suffix 'NL_I64'`

**Fix:** Add spaces around NL_I64 macro:
```cpp
// Before: toString("%" NL_I64 "u", value)
// After:  toString("%" NL_I64 "u", value)
```

### xmlFree Linking Error

**Error:** `unresolved external symbol xmlFree`

**Fix:** Rebuild NeL with `WITH_STATIC_LIBXML2=OFF`.

### zlib.h Not Found

**Error:** `Cannot open include file: 'zlib.h'`

**Fix:** Add `${ZLIB_INCLUDE_DIR}` to server CMakeLists.txt INCLUDE_DIRECTORIES.

---

## Runtime Errors

### Water Crash (DisplayWater = 2)

**Error:** Access Violation at water_task.cpp:170

**Cause:** WaterPoolManager not initialized.

**Workaround:** Set `DisplayWater = 0` in mtp_target_default.cfg.

### Wrong Water Texture (DisplayWater = 1)

**Symptom:** Pixelated arrow texture instead of water.

**Cause:** water_light.shape has wrong embedded texture reference.

**Workaround:** Set `DisplayWater = 0` in mtp_target_default.cfg.

---

## Scoring Not Working

See [SCORING_INVESTIGATION.md](SCORING_INVESTIGATION.md) for detailed investigation.

**Quick summary:**
- Level loader ignores Score/Friction in level files
- Must set via Lua `levelInit()` function
- Check server log for debug messages

---

## Log Locations

| Log | Location |
|-----|----------|
| Client | `build/bin/Release/log.log` |
| Server | `build/bin/Release/mtp_target_service.log` |
| Chat | `build/bin/Release/chat.log` |
| Crash dumps | `build/bin/Release/nel_report_*.log` |
| Login service | Terminal output (where deno runs) |

---

## Useful Commands

```bash
# Watch server log in real-time
tail -f build/bin/Release/mtp_target_service.log

# Search logs for errors
grep -i "error\|warning\|failed" build/bin/Release/mtp_target_service.log

# Check what's listening on ports
netstat -an | findstr "49997\|51574"

# Kill stuck processes
taskkill /F /IM mtp-target-forever-srv.exe
taskkill /F /IM mtp-target-forever.exe
```

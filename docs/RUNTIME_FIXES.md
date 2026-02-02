# Runtime Fixes & File Modifications

This document describes all the fixes required after building the client and server to make the game actually playable.

**Last Updated:** January 5, 2026

---

## Overview

After successfully building both the client (mtp-target-forever.exe) and server (mtp-target-forever-srv.exe), several runtime issues were discovered that prevented gameplay. This document catalogues each issue, its root cause, and the fix applied.

---

## Critical Crash Fixes

### 1. Client Crash: Water Rendering

**Symptom:**
- Client crashes with access violation (0xc0000005) at offset 0x196e3c
- Occurs during level loading after connecting to server

**Root Cause:**
- Water rendering code ([water_task.cpp:146-154](../client/src/water_task.cpp#L146-L154)) created textures with empty filenames
- Missing texture files: code referenced `.tga` but actual files are `.dds` format
- Missing files: `water_env.dds`, `water_disp.dds`, `water_disp2.dds`, `waterlight.dds`

**Fix (Session 7 - December 29, 2025):**
1. Fixed texture file extensions from `.tga` to `.dds` in [water_task.cpp](../client/src/water_task.cpp)
2. Copied missing water textures to `build/bin/Release/data/texture/`
3. Set `DisplayWater = 1` (basic water) as default

**DisplayWater Modes:**
- `DisplayWater = 0` - No water (original workaround)
- `DisplayWater = 1` - ✅ Basic water (static texture, works)
- `DisplayWater = 2` - ❌ Advanced water (crashes due to NeL3D compatibility issue)

**Advanced Water Issue (DisplayWater=2):**
- Crashes with assertion: `"_Mode==RotEuler || _Mode==RotQuat"` in transformable.h:107
- Root cause: NeL3D's CWaterModel transform mode not initialized correctly
- Problem is inside Ryzom Core's `CWaterShape::createInstance()` which calls `setPos()` before transform mode is set
- Not fixable without rebuilding/patching NeL3D library

**Status:** ✅ Basic water working (DisplayWater=1)

**Future:** Advanced water (DisplayWater=2) requires NeL3D library investigation/rebuild

---

### 2. Server Crash: Missing Level Files

**Symptom:**
- Server crashes immediately when client connects
- Failed assertion: `"levels.size() > 0"` at [level_manager.cpp:142](../server/src/level_manager.cpp#L142)

**Root Cause:**
- Server attempts to load a level when client connects
- No level files present in `build/bin/Release/data/level/`

**Fix:**
- Copied 69 level files from mtp-target-src (v1.5.19) to `data/level/`
- Level files are forward compatible (v1.5.19 levels work with v1.2.2a server)

**Command:**
```bash
mkdir -p build/bin/Release/data/level
cp mtp-target-src/data/level/*.lua build/bin/Release/data/level/
```

**Status:** ✅ Fixed - all 69 levels loaded successfully

---

### 3. Server Crash: Lua Script Path Errors

**Symptom:**
- Server crashes during level transitions
- Log shows: `Failed to load data/lua/level_darts_server.lua with error code 1`

**Root Cause:**
- All 71 level files referenced server Lua scripts with incorrect relative paths
- Level files contained: `ServerLua = "level_darts_server.lua"`
- Actual location: `data/lua/level_darts_server.lua`

**Fix:**
- Updated all 71 level files using sed:
```bash
cd build/bin/Release/data/level
sed -i 's/ServerLua = "\([^"]*\)"/ServerLua = "data\/lua\/\1"/' *.lua
```

**Example change:**
```diff
- ServerLua = "level_darts_server.lua"
+ ServerLua = "data/lua/level_darts_server.lua"
```

**Status:** ✅ Fixed - level transitions now work

---

### 3b. Server Crash: Lua 5.x Compatibility

**Symptom:**
- Server crashes during level transitions after fixing Lua script paths
- Log shows: `attempt to index a nil value (global 'CEntity')`
- Error occurs when loading Lua server scripts for certain levels

**Root Cause:**
- Lua 5.0 auto-created tables when defining methods: `function CEntity:init()` would create `CEntity` table
- Lua 5.x requires explicit table declaration before defining methods
- Level server scripts used pattern `function CEntity:method()` without declaring `CEntity = {}`

**Fix:**
Added table declarations to 14 Lua server scripts in [mtp-target-src/data/lua/](../mtp-target-src/data/lua/):
```lua
CEntity = CEntity or {}
CModule = CModule or {}  -- if needed
CLevel = CLevel or {}    -- if needed
```

**Files Modified:**
- level_bowls1_server.lua
- level_city_paint_server.lua
- level_darts_server.lua
- level_default_server.lua
- level_extra_ball_server.lua
- level_gates_server.lua
- level_paint_server.lua
- level_stairs_server.lua
- level_sun_extra_ball_server.lua
- level_team_server.lua
- And 4 more with similar patterns

**Also Updated:**
- [common/lua_utility.cpp:184-192](../common/lua_utility.cpp#L184-L192) - Added `lua_tostring()` error extraction for better debugging
- [scripts/post_build.sh](../scripts/post_build.sh#L130-L139) - Automatically copies Lua files with fixes
- [scripts/post_build.bat](../scripts/post_build.bat#L107-L116) - Windows version

**Status:** ✅ Fixed - server stable through all 71 level transitions

---

## Visual/Content Fixes

### 4. Wrong Skybox Theme

**Symptom:**
- Skybox displays city buildings instead of snow/antarctica theme
- Game is supposed to feature penguins in antarctic setting

**Root Cause:**
- Generic `sky.shape` file was a copy of `sky_city.shape`
- Data directory contains multiple skybox variants: `sky_snow.shape`, `sky_city.shape`, etc.

**Fix:**
```bash
cd build/bin/Release/data/shape
rm sky.shape
cp sky_snow.shape sky.shape
```

**Status:** ✅ Fixed - correct snowy skybox now displays

---

### 5. Penguin Visual Size Too Large

**Symptom:**
- Penguins rendered 100x too large compared to level geometry
- Camera too close, making penguin difficult to see properly

**Root Cause:**
- Entity mesh scaling not applied in client rendering code
- Scale factor GScale (0.01) defined but not used on mesh transform matrix

**Fix:**
Modified [client/src/entity.cpp:197-215](../client/src/entity.cpp#L197-L215):
```cpp
CMatrix m2 = _Mesh.getMatrix();
m2.setScale(CVector(2*GScale, 2*GScale, 2*GScale));  // Scale by 0.02
_Mesh.setMatrix(m2);
```

**Additional Fix - Camera Distance:**
Modified [mtp_target_default.cfg](../build/bin/Release/mtp_target_default.cfg#L254-L261):
- Camera distance values were 100x too large (matched old penguin scale)
- Updated to values from 1.5.19 source divided by 100
- Example: `CloseBackDist=3` → `CloseBackDist=0.03`

**Status:** ✅ Fixed - penguins now proper size, camera at correct distance

---

## Gameplay Fixes

### 6. Keyboard Controls Not Working

**Symptom:**
- Arrow keys don't steer the penguin in ball or gliding mode
- WASD keys type characters into chat instead of controlling movement
- User reports: "I can't control my pingoo at all"

**Root Cause:**
- Chat system ([chat_task.cpp:88](../client/src/chat_task.cpp#L88)) captures ALL keyboard input via `kbGetString()`
- This happens every frame, before control code can read key states
- Arrow keys and letter keys are consumed by chat before reaching [controler.cpp](../client/src/controler.cpp)

**Fix:**
Modified chat system to only capture input when explicitly activated:

**File: [client/src/chat_task.h](../client/src/chat_task.h)**
- Added `bool chatActive;` member variable

**File: [client/src/chat_task.cpp](../client/src/chat_task.cpp)**
- Initialize `chatActive = false` in `init()`
- Only call `kbGetString()` when `chatActive == true`
- Toggle chat mode on/off when Return/Enter key is pressed
- Allow Escape key to cancel chat mode
- Show visual cursor (`_`) when chat is active

**New Controls:**
- **Return/Enter:** Activate chat (press again to send message)
- **Escape:** Cancel chat without sending
- **Arrow keys:** Now work for steering (previously captured by chat)
- **CTRL:** Toggle between ball and gliding modes (unchanged)

**Status:** ✅ Fixed - full keyboard control restored

**Files Modified:**
- [client/src/chat_task.h](../client/src/chat_task.h): Added chatActive flag
- [client/src/chat_task.cpp](../client/src/chat_task.cpp): Implemented chat toggle logic

---

### 6b. Camera Controls - Zoom Reset on Mouse Drag

**Symptom:**
- Camera zoom resets to most zoomed-in view when left-clicking to rotate camera
- Annoying user experience - zoom setting doesn't persist during camera rotation

**Root Cause:**
- Mouse listener reset `MouseWheel = 0` on mouse button release
- This was in addition to resetting MouseX and MouseY rotation values

**Fix:**
Modified [client/src/mouse_listener.cpp:122-127,148-153](../client/src/mouse_listener.cpp#L122-L127):
- Removed `MouseWheel = 0;` from `EventMouseUpId` handlers (cases 2 and 3)
- Only MouseX and MouseY reset on mouse release, zoom level persists

**Additional Improvement - Default Zoom:**
Modified [client/src/mouse_listener.cpp:64,83](../client/src/mouse_listener.cpp#L64):
- Changed default from `MouseWheel = 0` (fully zoomed in) to `MouseWheel = 3` (2 steps out)
- Provides better starting view without manual zooming

**Status:** ✅ Fixed - zoom persists during camera rotation, better default view

---

## Missing Files & Dependencies

### 7. Missing Driver DLLs

**Symptom:**
- Client fails to start with error: `Load library 'nel_drv_opengl_win_r.dll' failed`

**Root Cause:**
- NeL drivers are separate DLLs built from Ryzom Core
- Not automatically copied to game directory

**Fix:**
Built and copied driver DLLs:
```bash
cd /c/ryzomcore/build
cmake --build . --config Release --target nel_drv_opengl_win -j 24
cmake --build . --config Release --target nel_drv_openal_win -j 24
cp bin/Release/nel_drv_opengl_win_r.dll /c/Users/User/Repos/mtp-target-forever/build/bin/Release/
cp bin/Release/nel_drv_openal_win_r.dll /c/Users/User/Repos/mtp-target-forever/build/bin/Release/
```

**Required Files:**
- `nel_drv_opengl_win_r.dll` (1.4 MB) - Graphics driver
- `nel_drv_openal_win_r.dll` (870 KB) - Sound driver

**Status:** ✅ Fixed - see post-build script below

---

### 8. Missing Font Files

**Symptom:**
- Client log shows: `PATH: File (n019003l.pfb) not found`

**Root Cause:**
- Font files not included in repository
- NeL requires specific PostScript and TrueType fonts

**Fix:**
Copied fonts from Ryzom Core samples:
```bash
mkdir -p build/bin/Release/data/font
cp /c/ryzomcore/nel/samples/3d/cegui/datafiles/n019003l.pfb \
   build/bin/Release/data/font/
cp /c/ryzomcore/nel/samples/3d/font/beteckna.ttf \
   build/bin/Release/data/font/bigfont.ttf
```

**Required Files:**
- `n019003l.pfb` (27 KB) - Century Schoolbook font
- `bigfont.ttf` (17 KB) - Display font (renamed from beteckna.ttf)

**Status:** ✅ Fixed - see post-build script below

---

### 9. Missing Configuration Variables

**Symptom:**
- Client crashes on startup: `Exception will be launched: variable "VSync" not found`

**Root Cause:**
- User config file missing required variables expected by client

**Fix:**
Added to `C:\Users\User\AppData\Roaming\mtp-target.cfg`:
```cfg
VSync                = 0;
AntiAlias            = 0;
SoundDriver          = "OpenAL";
MusicVolume          = 0.8000000000;
SoundVolume          = 0.8000000000;
```

**Status:** ✅ Fixed

---

## Automated Post-Build Setup

To avoid repeating these manual steps, use the provided post-build script:

**File:** [scripts/post_build.sh](../scripts/post_build.sh)

```bash
# Run after building client/server
./scripts/post_build.sh
```

The script automatically:
1. Copies driver DLLs from Ryzom Core
2. Copies font files
3. Creates data directory structure
4. Copies default config files
5. Verifies all required files are present

---

## Summary Table

| Issue | Component | Severity | Status | Fix Location |
|-------|-----------|----------|--------|--------------|
| Water rendering crash | Client | Critical | ✅ Fixed | water_task.cpp + config |
| Missing level files | Server | Critical | ✅ Fixed | Copied from archive |
| Lua script paths | Server | Critical | ✅ Fixed | Level files updated |
| Lua 5.x compatibility | Server | Critical | ✅ Fixed | 14 Lua server scripts |
| Wrong skybox | Client | Minor | ✅ Fixed | Replaced sky.shape |
| Penguin visual size | Client | Major | ✅ Fixed | entity.cpp + config |
| Camera distance | Client | Major | ✅ Fixed | mtp_target_default.cfg |
| Camera zoom reset | Client | Minor | ✅ Fixed | mouse_listener.cpp |
| Keyboard controls | Client | Critical | ✅ Fixed | chat_task.cpp/h |
| Missing drivers | Client | Critical | ✅ Fixed | Post-build script |
| Missing fonts | Client | Critical | ✅ Fixed | Post-build script |
| Missing config vars | Client | Minor | ✅ Fixed | User config |

---

## Configuration Files

### Client Configuration

**Primary Config:** `build/bin/Release/mtp_target_default.cfg`
- `DisplayWater = 1` - Basic water rendering (static texture)

**User Config:** `C:\Users\User\AppData\Roaming\mtp-target.cfg`
- Contains login credentials and user preferences

### Server Configuration

**Server Config:** `build/bin/Release/mtp_target_service.cfg`
- Copied from `server/mtp_target_service_default.cfg`
- Configures bot behavior, network settings, physics parameters

---

## Known Issues (Remaining)

### Advanced Water Mode (DisplayWater=2)
- **Impact:** Minor - basic water works, advanced water has better visuals
- **Status:** DisplayWater = 1 (basic water enabled, advanced disabled)
- **Advanced Mode (DisplayWater = 2):** Crashes with assertion in NeL3D CWaterModel
- **Basic Mode (DisplayWater = 1):** ✅ Working with static water texture
- **Root Cause:** NeL3D's CWaterShape::createInstance() calls setPos() before transform mode is set
- **Next Steps:**
  - Would require patching/rebuilding Ryzom Core's NeL3D library
  - Low priority since basic water is functional

---

## Future Improvements

1. **Automated Testing**
   - Script to verify all required files present
   - Checksum validation for copied files
   - Automated startup test

2. **Better Error Messages**
   - Detect missing files before crash
   - Guide user to run post-build script
   - Validate config files on startup

3. **Packaging**
   - Create installer that includes all dependencies
   - Bundle required fonts and textures
   - Pre-configure for local play

---

## References

- [BUILDING.md](BUILDING.md) - How to build client and server
- [MODIFICATIONS.md](MODIFICATIONS.md) - Source code changes for modern compatibility
- Post-build script: [scripts/post_build.sh](../scripts/post_build.sh)
- Build dependencies: [CONTINUATION_PROMPT.md](../CONTINUATION_PROMPT.md) (gitignored)

---

**Last Updated:** January 5, 2026
**Tested With:** Version 1.2.2a (client and server)
**Platform:** Windows 11, Visual Studio 2022 Build Tools
**Game Status:** Fully playable! 32 levels working, physics and scoring functional, basic water rendering.

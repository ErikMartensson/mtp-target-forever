# Changelog

All notable improvements and changes from the original MTP Target v1.2.2a.

## Client Improvements

### Options Menu (New)
In-game video options accessible from the main menu:
- **Resolution selection** - Cycle through available display modes (left-click forward, right-click backward)
- **Fullscreen toggle** - Switch between windowed and fullscreen modes
- **VSync toggle** - Enable/disable vertical sync
- Settings are saved to config file and game restarts automatically when Apply is clicked

### Aspect Ratio Fix
- Fixed stretched display on widescreen monitors (16:9, 21:9, etc.)
- Game was originally designed for 4:3 and hardcoded `1.33f` aspect ratio
- Camera perspective now calculates aspect ratio from actual screen dimensions
- Main menu background, logo, and dartboard now scale correctly without stretching

### HUD Speed Display
- Added speedometer to bottom-right corner of HUD (above score)
- Shows current speed as an integer value (scaled x100 for readability)
- Color-coded acceleration feedback:
  - **Green** - Accelerating
  - **Red** - Decelerating
  - **White** - Stable speed
- Uses dual exponential moving average (EMA) for smooth display

### Keyboard Controls Fix
- Fixed arrow keys being captured by chat input during gameplay
- Implemented chat toggle mode:
  - Press **Enter** to activate chat input
  - Type message and press **Enter** to send
  - Arrow keys now properly control penguin steering during gameplay

### Command-Line Arguments
- `--lan <host>` - Auto-connect to a LAN server
- `--user <name>` - Set player name for auto-connect
- Example: `tux-target.exe --lan localhost --user Player1`

### Right-Click Support
- Added right-click detection to GUI button system
- Used for cycling backwards through resolution options

## Physics Improvements

### Momentum Preservation
- Fixed momentum loss at ramp transitions
- Changed ODE contact mode from `dContactMu2` to `dContactApprox1` in physics.cpp
- Players now maintain speed when transitioning between surfaces

### Slope Steering
- Fixed inability to steer or accelerate on starting slopes
- Solution: Add explicit properties to slope modules:
  ```lua
  { Lua="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 }
  ```

## Server Improvements

### Level System
- All 32 playable snow/antarctic theme levels working
- All 4 team levels working with proper scoring
- Score/Friction/Accel/Bounce properties loaded from level Lua files
- Lua 5.2+ compatibility for module scripts

### Configuration
- `LevelPlaylist` config option for testing specific levels
- Network tick rate increased from 25Hz to 50Hz

## Build System

### Windows Build
- CMake 3.5+ compatibility
- MySQL made optional (login service uses SQLite)
- Fixed library linking order and dependencies
- Added build scripts: `scripts/build-client.bat`, `scripts/build-server.bat`
- Post-build script copies data files to build directories

### Source Modernization
- Lua 5.0 to 5.x compatibility layer (`common/lua_compat.h`)
- Updated NeL API calls for modern Ryzom Core
- Fixed C++11 compatibility issues (NL_I64 literal spacing)
- Added NLMISC namespace qualifiers where needed

## Files Changed (Summary)

### New Files
- `client/data/gui/options.xml` - Options menu layout
- `docs/CHANGELOG.md` - This file
- `common/lua_compat.h` - Lua compatibility macros
- `scripts/*.bat` - Build and run scripts

### Client Source
- `client/src/intro_task.cpp/h` - Options menu implementation
- `client/src/hud_task.cpp/h` - Speed display
- `client/src/chat_task.cpp/h` - Chat toggle mode
- `client/src/3d_task.cpp` - Aspect ratio fix
- `client/src/sky_task.cpp` - Aspect ratio fix (sky camera)
- `client/src/background_task.cpp` - Menu background scaling
- `client/src/gui_button.cpp/h` - Right-click support
- `client/src/gui_mouse_listener.cpp/h` - Right-click detection

### Server Source
- `server/src/physics.cpp` - Momentum preservation fix
- `server/src/module.cpp` - Lua 5.2+ compatibility
- `server/src/level.cpp` - Property loading from level files

## Version Strategy

This fork targets **v1.2.2a** compatibility for both client and server. The `reference/mtp-target-v1.5.19/` directory contains the last official client release for comparison and asset extraction.

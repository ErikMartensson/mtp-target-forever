# MTP Target Forever Controls

This document covers all controls for MTP Target Forever, from basic gameplay to advanced developer features.

## How to Play

MTP Target Forever is a penguin bowling/curling game. You roll down slopes and try to land on scoring targets. The higher the score on the target, the more points you earn.

### Game Phases

1. **Waiting** - Wait for enough players to join
2. **Ready** - Press any movement key when you're ready to start
3. **Rolling** - You start as a closed ball, rolling down the slope
4. **Flying** - Press Ctrl to open your wings and glide to the targets
5. **Scoring** - Land on targets to earn points. Higher targets = more points!

---

## Basic Controls

### Movement

| Key | Closed (Rolling) | Open (Flying) |
|-----|------------------|---------------|
| **Left/Right Arrow** | Steer left/right | Rotate/bank |
| **Up Arrow** | Accelerate forward | Pitch down (dive) |
| **Down Arrow** | Brake/slow down | Pitch up (climb) |

### Wings

| Key | Action |
|-----|--------|
| **Ctrl** (Left or Right) | Toggle wings open/closed |

- **Closed**: You're a rolling ball with momentum. Use arrow keys to steer.
- **Open**: You're a gliding penguin. Use arrow keys to control pitch and roll.

**Tip**: Open your wings when you want to aim for a specific target. Close them to pick up speed on slopes.

---

## Camera Controls

| Input | Action |
|-------|--------|
| **Left Click + Mouse** | Orbit camera around your penguin |
| **Mouse wheel** | Zoom in/out |

Hold down the left mouse button and move the mouse to look around. Release to return to the default view angle.

---

## Chat

| Key | Action |
|-----|--------|
| **Enter** | Open chat input / Send message |
| **Page Up** | Scroll chat history up |
| **Page Down** | Scroll chat history down |
| **End** | Jump to bottom and resume auto-scroll |
| **Escape** | Cancel chat input |

When chat is open, arrow keys type in the chat box. Press Enter to send or Escape to cancel.

### Chat Commands

Commands start with `/` and are typed in chat.

#### Player Commands (Everyone)

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/v <mapname>` | Vote for next level (short form) |
| `/votemap <mapname>` | Vote for next level |

#### Admin Commands

These require admin privileges (configured in server's `mtp_target_service.cfg`).

| Command | Description |
|---------|-------------|
| `/forcemap <mapname>` | Set the next level |
| `/forceend` | Force end current session and show scores |
| `/reset` | Hard reset of session (use with caution) |
| `/kick <name>` | Kick a player |
| `/ban <name> <duration>` | Ban a player |
| `/playerList` | List connected players |

---

## General Keys

| Key | Action |
|-----|--------|
| **Escape** | Exit game |
| **Pause** | Reset replay (only in replay mode) |

---

## Debug / Developer Keys

These are developer tools for testing and debugging. Some require admin privileges on the server.

### Visual Debug

| Key | Action | Status |
|-----|--------|--------|
| **F1** | Toggle level geometry visibility | Works |
| **Shift+F1** | Toggle start positions display | Non-functional |
| **F3** | Cycle polygon mode (solid / wireframe / points) | Works |
| **F4** | Toggle editor mode | Non-functional |
| **Ctrl+F4** | Toggle debug info overlay | Non-functional |

### Session Control (Admin Required)

| Key | Action |
|-----|--------|
| **Ctrl+F5** | Force end session (same as `/forceend`) |
| **Ctrl+F6** | Reset session (same as `/reset`) |

**Known Issue**: Ctrl+F6 (`/reset`) currently behaves identically to Ctrl+F5 (`/forceend`) - it advances to the next level instead of restarting the current session. This is a bug to be fixed in a future update.

### Bot Management (Disabled)

| Key | Action |
|-----|--------|
| **F5** | ~~Add bot~~ - **DISABLED** (caused server crashes) |
| **F6** | ~~Kick a bot~~ - **DISABLED** (caused server crashes) |

**Note**: Both F5 and F6 have been disabled because they caused server crashes. The bot system requires replay data and proper session state that isn't available during active gameplay.

### Camera / Spectator

| Key | Action |
|-----|--------|
| **F7** | Toggle free-look camera mode |
| **F8** | Release/capture mouse cursor |
| **F9** | View previous player |
| **F10** | View next player |
| **F11** | Reset to follow your own penguin |
| **F12** | Print camera position to log (for level editing) |
| **Alt+A** | Toggle external/preset camera view |

### Other

| Key | Action |
|-----|--------|
| **Alt+F2** | Take screenshot |
| **Shift+F1** | Toggle performance benchmark display |

---

## Level Editor Keys

When the level editor is enabled (F4), these keys are available:

| Key | Action |
|-----|--------|
| **F4** | Toggle editor mode |
| **Arrow keys** | Move camera |
| **Page Up/Down** | Move camera up/down |
| **Numpad 4/6** | Rotate view horizontally |
| **Numpad 8/5** | Adjust view angle vertically |
| **Shift** | Slow movement (fine control) |
| **Ctrl** | Fast movement |
| **Ctrl+Space** | Push selected element away from camera |

---

## Command Line Options

When launching the client:

```bash
# Connect to a LAN server
.\scripts\run-client.bat --lan localhost --user YourName

# Or manually:
mtp-target-forever.exe --lan <server-ip> --user <username>
```

| Option | Description |
|--------|-------------|
| `--lan <host>` | Connect to a LAN server at the specified address |
| `--user <name>` | Set your player name |

---

## Tips for New Players

1. **Start slow**: Don't open your wings too early. Build up speed on the slopes first.

2. **Aim for high-value targets**: Targets have different point values. The harder-to-reach ones are usually worth more.

3. **Watch other players**: Use F9/F10 to spectate and learn the best routes.

4. **Use the chat**: Type `/v mapname` to vote for your favorite levels.

5. **Practice gliding**: Open your wings and practice controlling your descent. Up arrow pitches down (dive), down arrow pitches up (climb).

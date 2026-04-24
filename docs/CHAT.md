# MTP Target Forever - Chat Reference

## Using Chat

Press **Enter** to open the chat input. Type your message and press **Enter** again to send. Press **Escape** to cancel without sending.

Maximum message length: 150 characters.

---

## Commands

Commands start with `/` and are case-insensitive.

### Player Commands

| Command | Description |
|---------|-------------|
| `/v <name>` | Vote for next level |
| `/votemap <name>` | Vote for next level (same as `/v`) |
| `/replay [comment]` | Mark current replay with a comment (client-side) |
| `/help` | Show available commands |

### Admin Commands

Everyone is admin by default in local/LAN play.

| Command | Description |
|---------|-------------|
| `/forcemap <name>` | Force next level |
| `/forceend` | End current session |
| `/reset` | Hard reset session |
| `/kick <name>` | Kick a player (disabled for bots) |
| `/ban <name> <duration>` | Ban a player |
| `/playerList` | List connected players |
| `/reparsePath` | Reparse file paths |

### Level Voting & Selection

Level matching uses **substring search** on the filename. Use unique substrings to avoid matching multiple levels.

Both `/v` and `/forcemap` validate levels immediately and show feedback:

| Situation | Response |
|-----------|----------|
| Level found and valid | `Vote registered: Arena (level_arena.lua)` or `Next level: Arena (level_arena.lua)` |
| No matching level | `No level found matching 'xyz'` |
| Level invalid | `Level level_xyz.lua is invalid: ReleaseLevel 0 not in allowed list` |

Votes require agreement from 1/3 + 1 of human players. Invalid votes are rejected with an error message.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Ctrl+F5** | Force end session (same as `/forceend`) |
| **Ctrl+F6** | Reset session (same as `/reset`) |

---

## Smileys

Type these codes in chat to display smiley icons. Codes are replaced with 16x16 images automatically.

| Code | Smiley | Code | Smiley |
|------|--------|------|--------|
| `:)` | Laugh | `:))` | Smile |
| `:)))` | Big grin | `;)` | Wink |
| `:(` | Cry | `:((` | Sad |
| `:/` | Doubt | `:s` | Confused |
| `:p` | Razz | `:O` | Surprised |
| `:i` | Neutral | `:red:` | Red face |
| `:roll:` | Eye roll | `:idea:` | Idea |
| `:mad:` | Mad | `:badgrin:` | Bad grin |
| `B)` | Cool | `8)` | Shocked |
| `>(` | Evil | `>)` | Twisted |
| `->` | Arrow right | `<-` | Arrow left |
| `lol` | Mr. Green | `gg` | Good game |
| `bg` | Bad game | `!!!` | Exclaim |
| `???` | Question | `:mt:` | MTP logo |

**Note:** Short codes like `gg`, `bg`, and `lol` are replaced even when part of normal words. Use with care.

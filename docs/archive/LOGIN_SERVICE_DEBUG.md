# Login Service Debugging Log

---

## CONTINUATION PROMPT FOR AI ASSISTANT

**Read this first to continue the debugging session:**

You are helping restore the MTP Target game to work with a local server. The game server and login service have been implemented, and we are debugging the final connection step.

**Current Blocker:** The SCS (Shard Choose Shard) message crashes the game client. We have tried ALL 8 combinations of ASCII/Wide encoding for the three SCS fields (reason, cookie, address), plus binary cookie format - ALL CRASH except error SCS (non-empty reason).

**What Works:**
- VLP (login) response - client successfully receives shard list
- CS (choose shard) message - client successfully sends this
- Error SCS - when reason is non-empty, client displays error without crashing

**What Fails:**
- Success SCS - when reason is empty and we include cookie + address, client crashes with "Stream Overflow"

**Key Finding from client log:**
```
Exception will be launched: stream does not contain at least 81690266 bytes for check
```
The number 81690266 (0x04DE7E9A) was the userKey from our binary cookie test - proving the client was misinterpreting our data as a string length.

**Hypothesis:** The SCS message format in the compiled binary (v1.5.19, version 708117) differs from the source code we have. The source shows `std::string` for cookie/address, but like VLP's ShardName (which required Wide despite source showing string), the binary may expect a completely different format.

**Next Steps to Try:**
1. Compile the original C++ login service and capture its exact SCS bytes
2. Reverse engineer the client binary to find the actual SCS parsing code
3. Try additional field variations (e.g., extra fields after address)

**MANDATORY:** After EVERY test, read ALL THREE logs:
1. Client: `C:\Users\User\AppData\Local\Temp\Mtp Target\log.log`
2. Game Server: `/home/byteme/mtp_target/mtp-target/server/src/mtp_target_service.log`
3. Login Service: Console output or `/tmp/login-service.log`

---

## UX Flow - Where We Are Stuck

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MTP TARGET CONNECTION FLOW                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  [1] Game Launch                                                             │
│      └── HTTP check to www.mtp-target.org ──────────────────────── ✅ WORKS │
│                                                                              │
│  [2] Login Screen                                                            │
│      └── User enters username/password                                       │
│      └── Client sends VLP to Login Service (port 49997) ─────────── ✅ WORKS │
│      └── Login Service responds with VLP (shard list) ──────────── ✅ WORKS │
│      └── Client displays server list ────────────────────────────── ✅ WORKS │
│                                                                              │
│  [3] Server Selection Screen                                                 │
│      └── User clicks "Connect" on a server                                   │
│      └── Client sends CS (Choose Shard) to Login Service ────────── ✅ WORKS │
│      └── Login Service responds with SCS ───────────────────────── ❌ CRASH │
│          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ │
│          WE ARE STUCK HERE - CLIENT CRASHES PARSING SCS MESSAGE              │
│                                                                              │
│  [4] Game Server Connection (NOT REACHED)                                    │
│      └── Client connects to Game Server (port 51574) with cookie            │
│      └── Game session begins                                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## MANDATORY: Log Checking Procedure

**After EVERY test attempt, you MUST read all three logs:**

```bash
# 1. Game Client Log (most important - shows crash details)
cat "/mnt/c/Users/User/AppData/Local/Temp/Mtp Target/log.log" | tail -50

# 2. Game Server Log (check for connection attempts)
tail -50 /home/byteme/mtp_target/mtp-target/server/src/mtp_target_service.log

# 3. Login Service Log (check SCS bytes sent)
# Either console output or:
cat /tmp/login-service.log | tail -50
```

**Why This Matters:**
- Client log reveals the exact error (e.g., "stream does not contain at least X bytes")
- Game server log shows if client ever attempts connection (currently: NO)
- Login service log shows exact bytes sent for verification

---

## Testing Process

### Required Services (in order of startup)
1. **Game Server** (WSL/Ubuntu) - Port 51574
2. **HTTP Server** (Windows/WSL with sudo) - Port 80
3. **Login Service** (WSL) - Port 49997
4. **Game Client** (Windows)

### Starting Services

```bash
# 1. Game Server (in WSL terminal 1)
cd /home/byteme/mtp_target/mtp-target/server/src
LD_LIBRARY_PATH=/home/byteme/mtp_target/ryzomcore/build/lib:$LD_LIBRARY_PATH ./mtp_target_service

# 2. HTTP Server (in WSL terminal 2, requires sudo for port 80)
cd /mnt/c/Users/User/Playground/mtp_target/login-service-deno
sudo deno task http

# 3. Login Service (in WSL terminal 3)
cd /mnt/c/Users/User/Playground/mtp_target/login-service-deno
deno task login

# 4. Game Client (Windows)
# Launch: C:\Program Files (x86)\Mtp Target\client\mtp_target.exe
```

### Test Credentials
- Username: `test`
- Password: `test`

### Hosts File Configuration
Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`) must contain:
```
127.0.0.1 mtp-target.dyndns.org
127.0.0.1 www.mtp-target.org
```

---

## SCS Test Matrix - Complete Results

### Legend
- **A** = ASCII string (std::string serialization: 4-byte length + ASCII bytes)
- **W** = Wide string (ucstring serialization: 4-byte char count + UTF-16LE bytes)
- **B** = Binary (raw uint32 values, no length prefix)
- **-** = Field not sent

### All Tests Performed (with corrected length calculation)

| # | Date | Reason | Cookie | Address | Result | Client Log Error |
|---|------|--------|--------|---------|--------|------------------|
| 1 | 12-18 | A | A | A | ❌ Crash | Stream Overflow |
| 2 | 12-18 | W | W | W | ❌ Crash | Stream Overflow |
| 3 | 12-18 | A | W | W | ❌ Crash | Error value 0x320033 |
| 4 | 12-18 | W | A | A | ❌ Crash | Stream Overflow |
| 5 | 12-18 | W | A | W | ❌ Crash | Error value 0x410046 |
| 6 | 12-21 | A | A | W | ❌ Crash | Stream Overflow |
| 7 | 12-18 | A | W | A | ❌ Crash | Stream Overflow |
| 8 | 12-21 | W | W | A | ❌ Crash | Stream Overflow |
| 9 | 12-21 | A (error) | - | - | ✅ WORKS | Client shows error msg |
| 10 | 12-21 | A (empty) | A | A | ❌ Crash | Cookie always sent |
| 11 | 12-21 | A (empty) | A | A | ❌ Crash | Cookie only on success |
| 12 | 12-21 | A (empty) | B (3×u32) | A | ❌ Crash | "at least 81690266 bytes" |
| 13 | 12-21 | A (empty) | W | W | ❌ Crash | Stream Overflow |

### Key Observations
1. **ALL encoding combinations crash** - the issue is NOT simple ASCII vs Wide
2. **Error SCS works** - the ONLY successful case is when reason is non-empty (error case)
3. **Test 12 revealed critical info** - client tried to read 81690266 bytes (our userKey as string length)
4. **Game server never sees connections** - crash happens before client connects to game server

---

## Critical Discovery: Source vs Binary Mismatch

The installed game client (v1.5.19, version code 708117) does NOT match the source code:

| Field | Source Code Type | Binary Behavior |
|-------|------------------|-----------------|
| VLP Login | `std::string` | Sent as Wide (UTF-16LE) |
| VLP ShardName | `std::string` | Expected as Wide (UTF-16LE) |
| SCS Cookie | `std::string` | Unknown - all formats crash |
| SCS Address | `std::string` | Unknown - all formats crash |
| Client Version | 0 (in source) | 708117 (in binary) |

---

## Technical Details

### NeL Serialization Formats
- `std::string`: `[4 bytes: length LE] [N bytes: ASCII data]`
- `ucstring`: `[4 bytes: char count LE] [N×2 bytes: UTF-16LE data]`

### Message Header Format
```
[4 bytes: Length BE] [1 byte: Format] [Payload...]
```
- Length = payload size (does NOT include format byte)
- Format = 0x01 (standard NeL format)

### CLoginCookie Format
String: `XXXXXXXX|YYYYYYYY|ZZZZZZZZ` (26 chars)
- UserAddr: 8 hex digits
- UserKey: 8 hex digits
- UserId: 8 hex digits

Binary: 3 × uint32 (12 bytes total)

---

## Code Locations

| Component | File | Key Function |
|-----------|------|--------------|
| Login Service (Deno) | `login-service-deno/login-only.ts` | CS message handler (~line 225) |
| NeL Protocol | `login-service-deno/nel-protocol-v2.ts` | Message serialization |
| Client VLP | `mtp-target/client/src/login_client.cpp` | `cbVerifyLoginPassword` |
| Client SCS | `mtp-target/client/src/login_client.cpp` | `cbShardChooseShard` (line 98) |
| Server SCS | `mtp-target/server/src/welcome.cpp` | `cbLSChooseShard` (line 120) |
| LS→Client SCS | `mtp-target/login_service/connection_ws.cpp` | `cbWSShardChooseShard` (line 315) |

---

## Possible Solutions to Explore

### 1. Compile Original C++ Login Service
- Capture exact bytes it sends for SCS
- Compare with our Deno implementation
- Files: `mtp-target/login_service/`

### 2. Reverse Engineer Client Binary
- Examine actual SCS parsing code in mtp_target.exe
- Find expected field types and order
- Tools: IDA Pro, Ghidra, x64dbg

### 3. Try Additional SCS Fields
- Maybe the binary expects extra fields we're not sending
- Check if there are version-specific additions

### 4. Network Packet Capture with Original Server
- If anyone has access to original server traffic
- Capture real SCS packet for reference

---

## Session Log

### 2025-12-21 Session Summary
- Tested all 8 ASCII/Wide combinations for SCS fields - all crash
- Tested binary cookie format (3×uint32) - crashes with revealing error
- Client log showed "at least 81690266 bytes" - this was our userKey value
- Confirmed client expects string cookie (not binary), but all string formats crash
- Game server shows NO connection attempts - crash is before game server connection

### Current State
- Login service: Running, correctly handling VLP and CS
- Game server: Running, waiting for connections (never receives any)
- Issue: SCS message format unknown for this client version

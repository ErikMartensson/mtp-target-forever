# NeL Network Protocol Notes

Technical reference for the NeL (Nevrax Engine Library) binary network protocol used by MTP Target.

**Status:** Active research - client binary may differ from source code
**Last Updated:** December 22, 2025

---

## Protocol Overview

MTP Target uses NeL's binary message format for all network communication:
- **Login Service ↔ Client** (port 49997)
- **Game Server ↔ Client** (ports 51574, 51575)
- **Login Service ↔ Game Server** (port 49999)

The protocol is **binary**, **stateful**, and uses **little-endian** byte order (except for the message length header).

---

## Message Structure

### Complete Message Format

```
┌─────────────────────────────────────────────────────────────┐
│ [4 bytes BE: Length] [1 byte: Format] [Variable: Payload]  │
└─────────────────────────────────────────────────────────────┘
```

**Header (5 bytes total):**
- **Bytes 0-3:** Message length (Big-Endian uint32)
  - Does **NOT** include the 4-byte length field itself
  - Does **NOT** include the 1-byte format field
  - Only counts the payload bytes
- **Byte 4:** Format type (always `0x01` for standard NeL messages)

**Payload:**
- Message type (serialized string)
- Message-specific fields

### Example: Empty Reason String

```
Offset  Hex                                        ASCII         Meaning
------  -----------------------------------------  ------------  ------------------
0x0000  00 00 00 04                                ....          Length: 4 bytes (BE)
0x0004  01                                         .             Format: 0x01
0x0005  00 00 00 00                                ....          String length: 0 (LE)
```

---

## Data Type Serialization

### String (std::string)

**Format:** `[4 bytes LE: length] [N bytes: ASCII data]`

Example - "VLP":
```
03 00 00 00 56 4C 50
├─length: 3  └─ "VLP"
```

### Wide String (ucstring / UTF-16LE)

**Format:** `[4 bytes LE: char count] [N×2 bytes: UTF-16LE data]`

Example - "Easy":
```
04 00 00 00 45 00 61 00 73 00 79 00
├─count: 4   └─ UTF-16LE: E.a.s.y.
```

**Important:** Count is number of characters, not bytes!

### Integers

| Type | Size | Endianness | Example (decimal 256) |
|------|------|------------|----------------------|
| uint8 | 1 byte | N/A | `00 01` |
| uint16 | 2 bytes | Little | `00 01` |
| uint32 | 4 bytes | Little | `00 01 00 00` |

### Boolean

`0x00` = false, `0x01` = true (1 byte)

---

## Message Types

### 1. VLP (Verify Login Password)

**Direction:** Login Service → Client
**Purpose:** Authentication response with shard list

#### Request (Client → Login Service)
```cpp
CMessage msgin("VLP");
string login;           // Player username
string password;        // Player password (plaintext on Windows, crypt on Linux)
string clientVersion;   // Build number as string (e.g., "708117")
```

#### Response (Login Service → Client)
```cpp
CMessage msgout("VLP");
string reason;          // Empty = success, non-empty = error message
uint32 nbShards;        // Number of available game servers
// For each shard:
ucstring shardName;     // ⚠️ WIDE STRING despite std::string in source!
uint8 nbPlayers;        // Current player count
uint32 shardId;         // Shard identifier
```

**Example Response (hex dump):**
```
00 00 00 21 01                               Header (33 bytes)
03 00 00 00 56 4C 50                         "VLP" message type
00 00 00 00                                  Empty reason (success)
01 00 00 00                                  1 shard
04 00 00 00 45 00 61 00 73 00 79 00          "Easy" (WIDE)
00                                           0 players
64 00 00 00                                  ShardId: 100
```

**Critical Discovery:** The source code shows `std::string` for shard name, but the binary expects `ucstring` (Wide). This is a **source/binary mismatch**.

---

### 2. CS (Choose Shard)

**Direction:** Client → Login Service
**Purpose:** Player selects a game server

```cpp
CMessage msgin("CS");
uint32 shardId;         // Selected shard ID
```

**Example (hex dump):**
```
00 00 00 06 01                               Header (6 bytes)
02 00 00 00 43 53                            "CS" message type
64 00 00 00                                  ShardId: 100
```

---

### 3. SCS (Shard Choose Shard) - ⚠️ PROBLEMATIC

**Direction:** Login Service → Client
**Purpose:** Provide game server address and session cookie

**According to Source Code:**
```cpp
CMessage msgout("SCS");
string reason;          // Empty = success, non-empty = error
string cookie;          // Session token (format: "XXXXXXXX|YYYYYYYY|ZZZZZZZZ")
string address;         // Game server address (e.g., "127.0.0.1:51574")
```

**⚠️ CRITICAL ISSUE:** The installed client (v1.5.19, build 708117) crashes on **ALL** encoding variations we've tested:
- ASCII reason + ASCII cookie + ASCII address = CRASH
- Wide reason + Wide cookie + Wide address = CRASH
- All 16 possible combinations tested = ALL CRASH
- Only works when reason is non-empty (error case)

**Current Theory:** Like VLP's shard name, the binary may expect different field types than the source shows. We need to either:
1. Compile the client from source to match
2. Reverse engineer the binary to find actual format
3. Capture real SCS traffic from original server

---

### 4. WS_IDENT (World Server Identification)

**Direction:** Game Server → Login Service
**Purpose:** Game server registration

```cpp
CMessage msgout("WS_IDENT");
sint32 shardId;         // Shard identifier
sint32 nbPlayers;       // Current player count
// For each connected player:
sint32 uid;             // User ID
```

---

## Common Patterns

### Empty vs Non-Empty Strings

**Empty string:**
```
00 00 00 00             Length: 0 (no data follows)
```

**Non-empty string "test":**
```
04 00 00 00 74 65 73 74
├─length: 4  └─ "test"
```

### Error Responses

Most responses use empty `reason` string for success:
```cpp
if (reason.empty()) {
    // Success - include additional data
} else {
    // Error - only send reason string
}
```

---

## Implementation Notes

### Deno/TypeScript Implementation

Our TypeScript login service (`login-service-deno/nel-protocol-v2.ts`) successfully implements:
- ✅ Message framing (4-byte BE length + 1-byte format)
- ✅ String serialization (ASCII)
- ✅ Wide string serialization (UTF-16LE)
- ✅ Integer serialization (little-endian)
- ✅ VLP response with Wide shard names
- ❌ SCS response (crashes client - format unknown)

### C++ Implementation

The original C++ code uses:
- `CMessage` class for message construction
- `serial()` methods for automatic serialization
- Template specialization for different types

**Example:**
```cpp
CMessage msgout("VLP");
string reason = "";
msgout.serial(reason);              // Serializes as ASCII string
uint32 nbShards = 1;
msgout.serial(nbShards);            // Serializes as LE uint32
ucstring shardName = "Easy";
msgout.serial(shardName);           // Serializes as UTF-16LE
```

---

## Binary/Source Mismatch Evidence

| Field | Source Code Type | Actual Binary Behavior |
|-------|------------------|------------------------|
| VLP: login | `std::string` | Sends as Wide (UTF-16LE) ✓ |
| VLP: shard name | `std::string` | **Expects Wide** ✓ |
| VLP: client version | `std::string` | Works as ASCII ✓ |
| SCS: reason | `std::string` | Unknown (all formats crash) ❌ |
| SCS: cookie | `std::string` | Unknown (all formats crash) ❌ |
| SCS: address | `std::string` | Unknown (all formats crash) ❌ |

**Conclusion:** The installed game client (v1.5.19, build 708117) does **NOT** match the source code in this repository. Either:
1. The source is from a different version
2. The binary was compiled with different settings
3. The client was patched after compilation

---

## Debugging Tools

### Hex Dump Format

We use this format in logs:
```
Offset  Hex
------  ------------------------------------------
0x0000  00 00 00 21 01 03 00 00 00 56 4C 50 00 00
0x0010  00 00 01 00 00 00 04 00 00 00 45 00 61 00
```

### Wireshark Dissector

For network traffic analysis, you could create a Wireshark dissector for NeL protocol. Key points:
- Messages are length-prefixed
- Big-endian length field
- Little-endian payload
- String types require special handling

### Test Message Generator

See `login-service-deno/test-scs-match.ts` for examples of generating test messages and comparing with C++ output.

---

## Known Issues

### 1. SCS Message Crashes
- **Status:** BLOCKED
- **Symptom:** Client crashes with "Stream Overflow" error
- **Tested:** 16 different encoding combinations
- **Next Step:** Compile client from source

### 2. Wide String Ambiguity
- **Status:** WORKAROUND FOUND
- **Issue:** Source shows `std::string` but binary expects `ucstring`
- **Solution:** Use Wide encoding for VLP shard names

### 3. Version Mismatch
- **Status:** CONFIRMED
- **Issue:** Client reports version 708117, source shows 0
- **Impact:** Protocol expectations may differ

---

## Network Ports

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| Login Service (Client) | 49997 | TCP | Authentication, shard list |
| Login Service (WS) | 49998 | TCP | Web API |
| Login Service (Welcome) | 49999 | TCP | Game server registration |
| Game Server (Easy) | 51574 | TCP | Gameplay |
| Game Server (Expert) | 51575 | TCP | Gameplay |
| HTTP Server | 80 | HTTP | Client startup checks |

---

## References

### Source Code Locations

| Component | File | Key Function |
|-----------|------|--------------|
| Client Login | `client/src/login_client.cpp` | `cbVerifyLoginPassword()` |
| Client SCS Handler | `client/src/login_client.cpp` | `cbShardChooseShard()` |
| LS → Client (VLP) | `login_service/connection_client.cpp` | `cbClientVerifyLoginPassword()` |
| LS → Client (SCS) | `login_service/connection_ws.cpp` | `cbWSShardChooseShard()` |
| Game Server (SCS) | `server/src/welcome.cpp` | `cbLSChooseShard()` |

### NeL Framework

- **Original:** http://www.nevrax.org (archived)
- **Modern Fork:** https://github.com/ryzom/ryzomcore
- **Documentation:** Limited, mostly in source code comments

---

## Future Work

- [ ] Reverse engineer SCS message format from client binary
- [ ] Compile client from source for protocol verification
- [ ] Document game server ↔ client protocol
- [ ] Create Wireshark dissector
- [ ] Capture original server traffic (if available)

---

## Questions?

For build issues, see [BUILDING.md](BUILDING.md).
For source code changes, see [MODIFICATIONS.md](MODIFICATIONS.md).

Protocol questions? Open an issue with hex dumps and tcpdump captures if possible.

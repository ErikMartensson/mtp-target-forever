/**
 * MTP Target Login Service - Standalone
 *
 * Handles TCP login connections on port 49997.
 * Does NOT require sudo/admin privileges.
 *
 * Usage: deno task login
 */

import { Database } from "jsr:@db/sqlite@0.12";
import { NelMessageV2 as NelMessage, NelMessageBufferV2 as NelMessageBuffer, packMessageV2 as packMessage } from "./nel-protocol-v2.ts";

const TCP_PORT = 49997;
const ACCEPT_NEW_USERS = true;

// Helper to get timestamp for logging (HH:MM:SS.mmm format)
function ts(): string {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const seconds = now.getSeconds().toString().padStart(2, '0');
    const millis = now.getMilliseconds().toString().padStart(3, '0');
    return `[${hours}:${minutes}:${seconds}.${millis}]`;
}

console.log("=== MTP Target Login Service ===");
console.log(`Port: ${TCP_PORT}`);
console.log(`Accept new users: ${ACCEPT_NEW_USERS}`);
console.log("");

const db = new Database("mtp_target.db");

interface ClientConnection {
    conn: Deno.Conn;
    uid: number | null;
    buffer: NelMessageBuffer;
}

const clients: Map<number, ClientConnection> = new Map();
let nextClientId = 0;

async function handleClient(conn: Deno.Conn) {
    const clientId = nextClientId++;
    const client: ClientConnection = {
        conn,
        uid: null,
        buffer: new NelMessageBuffer()
    };
    clients.set(clientId, client);

    const remoteAddr = conn.remoteAddr as Deno.NetAddr;
    console.log(`${ts()} [TCP ${clientId}] Client connected from ${remoteAddr.hostname}:${remoteAddr.port}`);

    try {
        const buffer = new Uint8Array(4096);

        while (true) {
            const n = await conn.read(buffer);
            if (n === null) {
                console.log(`${ts()} [TCP ${clientId}] Client disconnected`);
                break;
            }

            console.log(`${ts()} [TCP ${clientId}] Received ${n} bytes`);
            console.log(`${ts()} [TCP ${clientId}] Data: ${Array.from(buffer.slice(0, Math.min(n, 64))).map(b => b.toString(16).padStart(2, '0')).join(' ')}`);

            client.buffer.append(buffer.slice(0, n));

            // Process all complete messages in buffer
            let message: NelMessage | null;
            while ((message = client.buffer.tryParse()) !== null) {
                await handleMessage(clientId, client, message);
            }
        }
    } catch (error) {
        console.error(`${ts()} [TCP ${clientId}] Error:`, error.message);
    } finally {
        clients.delete(clientId);
        try {
            conn.close();
        } catch {
            // Connection already closed
        }
    }
}

async function handleMessage(clientId: number, client: ClientConnection, message: NelMessage) {
    console.log(`${ts()} [TCP ${clientId}] Received message: ${message.messageType}`);

    switch (message.messageType) {
        case "VLP":
            await handleVerifyLoginPassword(clientId, client, message);
            break;
        case "CS":
            await handleChooseShard(clientId, client, message);
            break;
        default:
            console.log(`${ts()} [TCP ${clientId}] Unknown message type: ${message.messageType}`);
    }
}

async function handleVerifyLoginPassword(clientId: number, client: ClientConnection, message: NelMessage) {
    console.log(`${ts()} [TCP ${clientId}] Processing login request...`);

    const login = message.readString();
    const password = message.readString();
    const clientVersion = message.readUint32();
    const osInfo = message.readString();
    const cpuInfo = message.readString();
    const memInfo = message.readString();
    const gfxInfo = message.readString();

    console.log(`[TCP ${clientId}] Login: '${login}'`);
    console.log(`[TCP ${clientId}] Client version: ${clientVersion}`);
    console.log(`[TCP ${clientId}] OS: ${osInfo}`);
    console.log(`[TCP ${clientId}] CPU: ${cpuInfo}`);
    console.log(`[TCP ${clientId}] Memory: ${memInfo}`);
    console.log(`[TCP ${clientId}] Graphics: ${gfxInfo}`);

    let reason = "";

    try {
        // Check if user exists
        const userQuery = db.prepare("SELECT * FROM user WHERE Login = ?");
        let user = userQuery.get(login);

        if (!user) {
            if (ACCEPT_NEW_USERS) {
                // Auto-create user
                const insertQuery = db.prepare(
                    "INSERT INTO user (Login, Password, State, Cookie, ShardId, Score, Texture, Registered, NbInvitations) VALUES (?, ?, 'Authorized', '', -1, 0, 0, datetime('now'), 0)"
                );
                insertQuery.run(login, password);
                user = userQuery.get(login);
                console.log(`[TCP ${clientId}] Created new user: ${login}`);
            } else {
                reason = "User not found";
            }
        } else {
            // Verify password (plaintext for Windows compatibility)
            if (user.Password !== password) {
                reason = "Invalid password";
            }
        }

        if (!reason && user) {
            // Update user state and generate cookie
            const cookie = generateCookie(user.UId as number);
            const updateQuery = db.prepare("UPDATE user SET State = 'Authorized', Cookie = ? WHERE UId = ?");
            updateQuery.run(cookie, user.UId);
            client.uid = user.UId as number;
            console.log(`[TCP ${clientId}] Authentication successful! UID: ${user.UId}`);
        }
    } catch (error) {
        reason = `Database error: ${error.message}`;
        console.error(`[TCP ${clientId}] Error during auth:`, error);
    }

    // Get online shards
    const shardsQuery = db.prepare("SELECT * FROM shard WHERE State = 'Online'");
    const shards = shardsQuery.all();
    console.log(`[TCP ${clientId}] Online shards: ${shards.length}`);

    // Send success response
    const response = NelMessage.create("VLP");
    response.writeString(reason); // Empty string = success
    response.writeUint32(shards.length);

    // Serialize shard list
    for (const shard of shards) {
        // MTP Target client expects wide string (UTF-16LE) for shard name
        // (even though source shows std::string, the compiled binary expects ucstring)
        response.writeWideString(shard.Name as string);
        response.writeUint8(shard.NbPlayers as number);
        response.writeUint32(shard.ShardId as number);
    }

    const responseBytes = packMessage(response);
    console.log(`${ts()} [TCP ${clientId}] Sent VLP response (${shards.length} shards)`);
    console.log(`${ts()} [TCP ${clientId}] Response bytes: ${Array.from(responseBytes.slice(0, Math.min(responseBytes.length, 128))).map(b => b.toString(16).padStart(2, '0')).join(' ')}`);
    console.log(`${ts()} [TCP ${clientId}] VLP response is ${responseBytes.length} bytes total`);
    console.log(`${ts()} [TCP ${clientId}] Expected: 37 bytes (5 header + 32 payload)`);
    console.log(`${ts()} [TCP ${clientId}] Breakdown: VLP(7) + Reason(4) + nbShards(4) + ShardName_WIDE(4+8) + NbPlayers(1) + ShardId(4) = 32 bytes payload`);
    await client.conn.write(responseBytes);
    console.log(`${ts()} [TCP ${clientId}] VLP response WRITE COMPLETED, waiting for CS message...`);
}

async function handleChooseShard(clientId: number, client: ClientConnection, message: NelMessage) {
    console.log(`${ts()} [TCP ${clientId}] Processing shard selection...`);

    const shardId = message.readUint32();
    console.log(`[TCP ${clientId}] Selected shard ID: ${shardId}`);

    let reason = "";

    try {
        // Verify user is authorized
        if (!client.uid) {
            reason = "Not authorized to select a shard";
        } else {
            // Get shard info
            const shardQuery = db.prepare("SELECT * FROM shard WHERE ShardId = ? AND State = 'Online'");
            const shard = shardQuery.get(shardId);

            if (!shard) {
                reason = "Shard not found or offline";
            } else {
                // Get user's cookie
                const userQuery = db.prepare("SELECT Cookie FROM user WHERE UId = ?");
                const user = userQuery.get(client.uid);

                if (!user) {
                    reason = "User not found";
                } else {
                    const cookie = user.Cookie as string;
                    // The address MUST include the port
                    const shardAddress = (shard as Record<string, unknown>).Address as string || "127.0.0.1";
                    const shardPort = (shard as Record<string, unknown>).Port as number || 51574;
                    const address = `${shardAddress}:${shardPort}`;

                    console.log(`${ts()} [TCP ${clientId}] Shard selected: ${shard.Name}`);
                    console.log(`${ts()} [TCP ${clientId}] Address: ${address}`);
                    console.log(`${ts()} [TCP ${clientId}] Cookie: ${cookie}`);

                    // TEST #14: Use exact C++ CMessage format from hex dump
                    // All fields are ASCII std::string (not Wide!)
                    console.log(`${ts()} [TCP ${clientId}] Building SCS with EXACT C++ format`);

                    const responseBytes = buildExactSCS(reason, cookie, address);
                    console.log(`${ts()} [TCP ${clientId}] SCS Response bytes (${responseBytes.length}):`);
                    for (let i = 0; i < responseBytes.length; i += 16) {
                        const hex = Array.from(responseBytes.slice(i, Math.min(i + 16, responseBytes.length)))
                            .map(b => b.toString(16).padStart(2, '0')).join(' ');
                        console.log(`${ts()} [TCP ${clientId}]   ${hex}`);
                    }
                    await client.conn.write(responseBytes);
                    console.log(`${ts()} [TCP ${clientId}] SCS response sent successfully`);
                    return;
                }
            }
        }
    } catch (error) {
        reason = `Database error: ${error.message}`;
        console.error(`${ts()} [TCP ${clientId}] Error during shard selection:`, error);
    }

    // Send error response (no cookie or address on error)
    console.log(`${ts()} [TCP ${clientId}] Shard selection failed: ${reason}`);
    const errorBytes = buildExactSCS(reason, "", "");  // Empty cookie and address on error
    await client.conn.write(errorBytes);
}

function generateCookie(uid: number): string {
    // Format: XXXXXXXX|YYYYYYYY|ZZZZZZZZ
    const userAddr = 0;
    const userKey = Math.floor(Math.random() * 0xFFFFFFFF);
    const userId = uid;

    const toHex = (n: number) => n.toString(16).toUpperCase().padStart(8, '0');
    return `${toHex(userAddr)}|${toHex(userKey)}|${toHex(userId)}`;
}

// Build SCS message exactly matching C++ CMessage format
function buildExactSCS(reason: string, cookie: string, address: string): Uint8Array {
    // C++ CMessage sends over TCP:
    // [4 bytes BE: length] [1 byte: format] [string: msgType] [payload...]
    // The buffer() method's first 4 bytes (123) appear to be internal metadata, NOT sent on wire!

    const msgType = "SCS";

    // Build the internal message (without TCP length header)
    // Cookie and address ONLY sent on success (when reason is empty) - matching login_client.cpp
    const internalSize =
        1 +  // format byte
        4 + msgType.length +  // message type string (ASCII)
        4 + reason.length +   // reason string (ASCII)
        (reason.length === 0 ? (4 + cookie.length + 4 + address.length) : 0); // cookie + address only if success

    const internal = new Uint8Array(internalSize);
    const view = new DataView(internal.buffer);
    let pos = 0;

    // Format byte
    internal[pos++] = 0x01;

    // Message type (std::string)
    view.setUint32(pos, msgType.length, true);
    pos += 4;
    for (let i = 0; i < msgType.length; i++) {
        internal[pos++] = msgType.charCodeAt(i);
    }

    // Reason (std::string - ASCII)
    view.setUint32(pos, reason.length, true);
    pos += 4;
    for (let i = 0; i < reason.length; i++) {
        internal[pos++] = reason.charCodeAt(i);
    }

    // Cookie and Address - ONLY if success (reason empty) - matching login_client.cpp behavior
    if (reason.length === 0) {
        // Cookie (std::string - ASCII)
        view.setUint32(pos, cookie.length, true);
        pos += 4;
        for (let i = 0; i < cookie.length; i++) {
            internal[pos++] = cookie.charCodeAt(i);
        }

        // Address (std::string - ASCII)
        view.setUint32(pos, address.length, true);
        pos += 4;
        for (let i = 0; i < address.length; i++) {
            internal[pos++] = address.charCodeAt(i);
        }
    }

    // Wrap in TCP packet: [4 bytes BE length] [internal message]
    const packet = new Uint8Array(4 + internalSize);
    const packetView = new DataView(packet.buffer);
    packetView.setUint32(0, internalSize, false); // Big-endian length
    packet.set(internal, 4);

    return packet;
}

async function startTcpServer() {
    const listener = Deno.listen({ port: TCP_PORT });
    console.log(`${ts()} [TCP] Ready to accept connections on port ${TCP_PORT}`);

    for await (const conn of listener) {
        handleClient(conn);
    }
}

startTcpServer();

/**
 * NeL Network Protocol Implementation - Version 2
 *
 * Based on reverse-engineering the actual MTP Target client messages.
 *
 * MTP Target uses an OLDER NeL protocol (no packet number):
 *   [4 bytes: Length (big-endian)] - Length of everything after this field
 *   [1 byte: Format] - TFormat bitfield (LongFormat, StringMode, MessageType)
 *   [4 bytes: Name Length (little-endian)] + [N bytes: Name] - Message type as std::string
 *   [... payload ...]
 *
 * Note: Modern NeL (RyzomCore) adds a 4-byte packet number, but MTP Target doesn't use it.
 */

export class NelMessageV2 {
    private buffer: Uint8Array;
    private view: DataView;
    private position: number;
    public messageType: string;
    public formatByte: number;

    constructor(data: Uint8Array) {
        // Input data starts AFTER the 4-byte length header
        // Structure: [1 byte: format] [string: name] [payload...]
        this.buffer = data;
        this.view = new DataView(data.buffer, data.byteOffset, data.byteLength);
        this.position = 0;

        // Read format byte (1 byte)
        this.formatByte = this.view.getUint8(this.position);
        this.position += 1;

        // Read message type (first string in message)
        this.messageType = this.readString();
        console.log(`[NelMessageV2] Parsed: format=0x${this.formatByte.toString(16)}, type="${this.messageType}"`);
    }

    static create(messageType: string): NelMessageV2 {
        const msg = Object.create(NelMessageV2.prototype);
        msg.buffer = new Uint8Array(1024);
        msg.view = new DataView(msg.buffer.buffer);
        msg.position = 0;
        msg.messageType = messageType;
        msg.formatByte = 0x01; // LongFormat=1, StringMode=0, MessageType=0 (OneWay)
        // Write message type as first string in payload
        msg.writeString(messageType);
        return msg;
    }

    readUint8(): number {
        const value = this.view.getUint8(this.position);
        this.position += 1;
        return value;
    }

    readUint32(): number {
        const value = this.view.getUint32(this.position, true); // little-endian
        this.position += 4;
        return value;
    }

    readInt32(): number {
        const value = this.view.getInt32(this.position, true); // little-endian
        this.position += 4;
        return value;
    }

    readString(): string {
        const charCount = this.readUint32();
        console.log(`[NelMessageV2] Reading string with ${charCount} characters`);

        if (charCount === 0) {
            return "";
        }

        // Check if we have enough data for wide chars (2 bytes per char)
        if (this.position + charCount * 2 <= this.buffer.length) {
            // Check if it looks like UTF-16LE by examining the pattern
            // In UTF-16LE ASCII strings, every second byte is 0x00
            let looksLikeWide = true;
            for (let i = 1; i < Math.min(charCount * 2, 8); i += 2) {
                if (this.buffer[this.position + i] !== 0x00) {
                    looksLikeWide = false;
                    break;
                }
            }

            if (looksLikeWide) {
                // Read as UTF-16LE
                const wideBytes = new Uint8Array(this.buffer.buffer, this.buffer.byteOffset + this.position, charCount * 2);
                this.position += charCount * 2;
                const wideStr = new TextDecoder('utf-16le').decode(wideBytes);
                console.log(`[NelMessageV2] Read wide string: "${wideStr}"`);
                return wideStr;
            }
        }

        // Try reading as regular ASCII/UTF-8 (1 byte per char)
        if (this.position + charCount <= this.buffer.length) {
            const bytes = new Uint8Array(this.buffer.buffer, this.buffer.byteOffset + this.position, charCount);
            this.position += charCount;
            const str = new TextDecoder('utf-8').decode(bytes);
            console.log(`[NelMessageV2] Read ASCII string: "${str}"`);
            return str;
        }

        throw new Error(`Not enough data to read string of ${charCount} characters`);
    }

    writeUint8(value: number): void {
        this.view.setUint8(this.position, value);
        this.position += 1;
    }

    writeUint32(value: number): void {
        this.view.setUint32(this.position, value, true); // little-endian
        this.position += 4;
    }

    writeInt32(value: number): void {
        this.view.setInt32(this.position, value, true); // little-endian
        this.position += 4;
    }

    writeString(value: string): void {
        const encoded = new TextEncoder().encode(value);
        this.writeUint32(encoded.length);
        this.buffer.set(encoded, this.position);
        this.position += encoded.length;
    }

    writeAsciiString(value: string): void {
        const length = value.length;
        this.writeUint32(length);
        for (let i = 0; i < length; i++) {
            this.writeUint8(value.charCodeAt(i) & 0xFF);
        }
    }

    writeWideString(value: string): void {
        const chars = [];
        for (let i = 0; i < value.length; i++) {
            chars.push(value.charCodeAt(i));
            chars.push(0);
        }
        const encoded = new Uint8Array(chars);
        this.writeUint32(value.length); // Number of characters
        this.buffer.set(encoded, this.position);
        this.position += encoded.length;
    }

    getBytes(): Uint8Array {
        // Message payload (message type string + actual payload data)
        const messageData = this.buffer.slice(0, this.position);

        // Build the internal buffer:
        // [1 byte: format] [N bytes: messageData]
        const internalSize = 1 + messageData.length;
        const internal = new Uint8Array(internalSize);

        // Write format byte
        internal[0] = this.formatByte;

        // Write message data (message type string + payload)
        internal.set(messageData, 1);

        // Build final packet:
        // [4 bytes: length (big-endian)] [internal buffer]
        const result = new Uint8Array(4 + internalSize);
        const resultView = new DataView(result.buffer);

        // Length = size of internal buffer (format + messageData)
        resultView.setUint32(0, internalSize, false); // Big-endian length

        // Copy internal buffer
        result.set(internal, 4);

        return result;
    }

    getLength(): number {
        return this.position;
    }
}

export class NelMessageBufferV2 {
    private buffer: Uint8Array;

    constructor() {
        this.buffer = new Uint8Array(0);
    }

    append(data: Uint8Array): void {
        const newBuffer = new Uint8Array(this.buffer.length + data.length);
        newBuffer.set(this.buffer);
        newBuffer.set(data, this.buffer.length);
        this.buffer = newBuffer;
    }

    tryParse(): NelMessageV2 | null {
        console.log(`[NelMessageBufferV2] Buffer size: ${this.buffer.length}`);
        if (this.buffer.length > 0) {
            console.log(`[NelMessageBufferV2] First 32 bytes: ${Array.from(this.buffer.slice(0, Math.min(32, this.buffer.length))).map(b => b.toString(16).padStart(2, '0')).join(' ')}`);
        }

        // Header size is 4 bytes: [Length (4, big-endian)]
        if (this.buffer.length < 4) {
            return null;
        }

        const view = new DataView(this.buffer.buffer, this.buffer.byteOffset, this.buffer.byteLength);
        const length = view.getUint32(0, false); // Big-endian length

        // Check if we have the full message
        // Total size = 4 (length header) + length (internal data)
        if (this.buffer.length < 4 + length) {
            console.log(`[NelMessageBufferV2] Not enough data yet. Have ${this.buffer.length}, need ${4 + length}`);
            return null;
        }

        // Extract the internal data: [format] [name string] [payload...]
        const internalData = this.buffer.slice(4, 4 + length);

        // Remove from buffer
        const newBuffer = new Uint8Array(this.buffer.length - (4 + length));
        newBuffer.set(this.buffer.slice(4 + length));
        this.buffer = newBuffer;

        try {
            return new NelMessageV2(internalData);
        } catch (e: unknown) {
            const error = e as Error;
            console.error(`[NelMessageBufferV2] Parse error:`, error.message);
            return null;
        }
    }

    // Legacy method name for compatibility
    extractMessage(): NelMessageV2 | null {
        return this.tryParse();
    }

    clear(): void {
        this.buffer = new Uint8Array(0);
    }
}

export function packMessageV2(message: NelMessageV2): Uint8Array {
    return message.getBytes();
}

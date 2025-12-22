import { Database } from "jsr:@db/sqlite@0.12";

const db = new Database("mtp_target.db");

console.log("Creating database schema...");

// Create user table
db.exec(`
CREATE TABLE IF NOT EXISTS user (
    UId INTEGER PRIMARY KEY AUTOINCREMENT,
    Login TEXT NOT NULL UNIQUE,
    Password TEXT NOT NULL,
    State TEXT DEFAULT 'Offline' CHECK(State IN ('Offline', 'Authorized', 'Online')),
    Cookie TEXT DEFAULT '',
    ShardId INTEGER DEFAULT -1,
    Score INTEGER DEFAULT 0,
    Texture INTEGER DEFAULT 0,
    Registered DATETIME DEFAULT CURRENT_TIMESTAMP,
    NbInvitations INTEGER DEFAULT 0
)
`);

// Create shard table
db.exec(`
CREATE TABLE IF NOT EXISTS shard (
    ShardId INTEGER PRIMARY KEY,
    Name TEXT NOT NULL,
    NbPlayers INTEGER DEFAULT 0,
    State TEXT DEFAULT 'Offline' CHECK(State IN ('Offline', 'Online')),
    InternalId INTEGER DEFAULT 0,
    Address TEXT,
    Port INTEGER
)
`);

// Create ban table
db.exec(`
CREATE TABLE IF NOT EXISTS ban (
    Ip TEXT PRIMARY KEY,
    Reason TEXT,
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Duration INTEGER DEFAULT 0
)
`);

console.log("Schema created successfully!");

// Add a test user (password: "test" - we'll use plaintext for Windows compatibility)
console.log("\nAdding test user...");
try {
    db.exec(`
        INSERT INTO user (Login, Password, Registered)
        VALUES ('test', 'test', datetime('now'))
    `);
    console.log("Test user created: login='test', password='test'");
} catch (e) {
    console.log("Test user already exists (or error):", e.message);
}

// Add a test shard (game server) - initially offline
console.log("\nAdding test shard...");
try {
    db.exec(`
        INSERT INTO shard (ShardId, Name, NbPlayers, State, InternalId, Address, Port)
        VALUES (1, 'Local Test Server', 0, 'Offline', 1, 'localhost', 51574)
    `);
    console.log("Test shard created: 'Local Test Server' (Offline)");
} catch (e) {
    console.log("Test shard already exists (or error):", e.message);
}

// Show current data
console.log("\n=== Current Users ===");
const users = db.prepare("SELECT UId, Login, State, Registered FROM user").all();
console.table(users);

console.log("\n=== Current Shards ===");
const shards = db.prepare("SELECT ShardId, Name, NbPlayers, State, Address, Port FROM shard").all();
console.table(shards);

db.close();

console.log("\nDatabase setup complete!");
console.log("\nNOTE: The test shard is 'Offline'. You'll need a game server to set it 'Online'.");
console.log("For now, login will work but you won't see any servers available.");

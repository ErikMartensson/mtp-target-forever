/**
 * MTP Target HTTP Server - Standalone
 *
 * Handles HTTP requests from the game client during startup.
 * Must run with sudo/admin privileges to bind to port 80.
 *
 * Usage: sudo deno task http
 */

const HTTP_PORT = parseInt(Deno.env.get("HTTP_PORT") || "80");

console.log("=== MTP Target HTTP Server ===");
console.log(`Port: ${HTTP_PORT}`);
console.log("");

async function startHttpServer() {
    console.log(`[HTTP] Starting HTTP server on port ${HTTP_PORT}...`);

    try {
        await Deno.serve({ port: HTTP_PORT, hostname: "0.0.0.0" }, async (req) => {
            const url = new URL(req.url);
            const timestamp = new Date().toLocaleTimeString();
            console.log(`[${timestamp}] [HTTP] ${req.method} ${url.pathname}`);

            // Log crash reports
            if (url.pathname.includes("mt_crash_report.php")) {
                const body = await req.text();
                console.log("[HTTP] === CRASH REPORT ===");
                console.log(body);
                console.log("[HTTP] === END CRASH REPORT ===");
                return new Response("OK", {
                    headers: { "Content-Type": "text/plain" }
                });
            }

            // Default response - empty but valid HTML
            const defaultHtml = `<!DOCTYPE html>
<html>
<head><title>MTP Target Server</title></head>
<body>
<h1>MTP Target Local Server</h1>
<p>Server is running.</p>
</body>
</html>`;

            // Serve empty CRC file
            if (url.pathname.includes("crc.txt") || url.pathname.includes("crc.php")) {
                console.log("[HTTP] Serving empty CRC file");
                return new Response("", {
                    headers: { "Content-Type": "text/plain" }
                });
            }

            // Serve empty export directory listings
            if (url.pathname.includes("/export")) {
                console.log("[HTTP] Serving export directory response");
                return new Response("", {
                    headers: { "Content-Type": "text/plain" }
                });
            }

            // Default: serve minimal HTML
            return new Response(defaultHtml, {
                headers: { "Content-Type": "text/html" }
            });
        }).finished;
    } catch (error) {
        if (error.name === "AddrInUse") {
            console.error(`\n[HTTP] ERROR: Port ${HTTP_PORT} is already in use!`);
            console.error("[HTTP] Try: sudo lsof -i :80");
            Deno.exit(1);
        } else {
            console.error(`[HTTP] Unexpected error:`, error);
            Deno.exit(1);
        }
    }
}

startHttpServer();

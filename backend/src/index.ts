import http from "node:http";
import { Server } from "socket.io";
import { env } from "./config/env.js";
import { logger } from "./lib/logger.js";
import { connectPrisma, disconnectPrisma } from "./lib/prisma.js";
import { disconnectRedis } from "./lib/redis.js";
import { createApp } from "./app.js";
import { attachSignaling } from "./modules/signaling/signaling.gateway.js";

async function main(): Promise<void> {
  await connectPrisma();
  const app = createApp();
  const server = http.createServer(app);
  const io = new Server(server, {
    cors: { origin: [...env.CORS_ORIGINS, ...env.MASKED_ORIGINS], credentials: true },
    pingInterval: env.SIGNALING_PING_INTERVAL_MS,
    pingTimeout: 20000,
    maxHttpBufferSize: env.SIGNALING_MAX_BUFFER_SIZE,
    perMessageDeflate: false,
    allowEIO3: false,
  });
  attachSignaling(io);

  server.listen(env.PORT, env.HOST, () => {
    logger.info({ host: env.HOST, port: env.PORT }, "nexus api listening");
  });

  const shutdown = async (signal: string) => {
    logger.info({ signal }, "shutting down");
    io.close();
    server.close();
    await disconnectPrisma();
    await disconnectRedis();
    process.exit(0);
  };
  process.on("SIGINT", () => void shutdown("SIGINT"));
  process.on("SIGTERM", () => void shutdown("SIGTERM"));
}

main().catch((err) => {
  logger.fatal({ err }, "failed to start");
  process.exit(1);
});

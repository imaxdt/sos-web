import 'dotenv/config';
import Fastify from 'fastify';
import cors from '@fastify/cors';
import { PrismaClient } from '@prisma/client';

const app = Fastify({
  logger: true
});

const prisma = new PrismaClient();

await app.register(cors, {
  origin: true,
  credentials: true
});

app.get('/health', async () => {
  return {
    ok: true,
    service: 'sos-web-backend',
    env: process.env.APP_ENV ?? 'development',
    time: new Date().toISOString()
  };
});

app.get('/health/db', async () => {
  await prisma.$queryRaw`SELECT 1`;
  return {
    ok: true,
    database: 'connected'
  };
});

const port = Number(process.env.APP_PORT ?? 3000);
const host = process.env.APP_HOST ?? '0.0.0.0';

try {
  await app.listen({ port, host });
} catch (error) {
  app.log.error(error);
  process.exit(1);
}

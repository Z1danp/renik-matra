import { PrismaClient } from "@prisma/client/extension";
import { Pool, neon } from "@neondatabase/serverless";

export const prisma = new PrismaClient({
  log: ["error", "warn"],
});

export const rawPool = new Pool({
    connectionString: process.env.DATABASE_URL
})

export const sql = neon(process.env.DATABASE_URL!)

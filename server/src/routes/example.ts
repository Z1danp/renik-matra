import express from 'express';
import { prisma, sql } from '../db/pool';

const router = express.Router();

router.get('/hybrid-example', async (req, res) => {
  try {
    // Penggunaan Prisma
    const users = await prisma.user.findMany();

    // Penggunaan Raw Query Neon HTTP
    const rawResult = await sql`SELECT NOW() as current_time`;

    res.json({ 
      users, 
      time: rawResult[0].current_time 
    });
  } catch (error) {
    res.status(500).json({ error: 'Database error' });
  }
});

export default router;
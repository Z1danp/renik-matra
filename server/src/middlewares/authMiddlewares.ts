import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import type { NextFunction, Request, Response } from "express";

dotenv.config();

function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const token = req.cookies?.token;

  if (!token) return res.status(401).json({ error: "Unauthorized" });

  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) throw new Error("JWT_SECRET is not set");
    req.user = jwt.verify(token, secret) as jwt.JwtPayload;
    next();
  } catch {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

export default authMiddleware;

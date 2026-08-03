import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import productsRouter from "./routes/products";

const app = express();
const port = Number(process.env.PORT ?? 4000);

app.use(cors());
app.use(express.json());
app.use(cookieParser());

app.use("/api/products", productsRouter);

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port} \nlistening color your night`);
});

import { Router } from "express";
import type { Request, Response } from "express";
import { z } from "zod";
import type { ProductListResponse, ProductListErrorResponse } from "../../../types/product.js";

const router = Router();

// deklarasi schema & aturan validasi
const productQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(10),
  search: z
    .string()
    .trim()
    .transform((val) => (val === "" ? null : val))
    .optional()
    .default(null),
  category: z
    .string()
    .trim()
    .transform((val) => (val === "" ? null : val))
    .optional()
    .default(null),
  sortBy: z.enum(["latest", "price-asc", "price-desc"]).default("latest"),
});

type ProductListQuery = z.infer<typeof productQuerySchema>;

router.get(
  "/",
  (
    req: Request,
    res: Response<ProductListResponse | ProductListErrorResponse>,
  ) => {
    const result = productQuerySchema.safeParse(req.query);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: "Invalid query parameters",
        errors: result.error.flatten().fieldErrors,
      });
    }

    const query: ProductListQuery = result.data;

    res.json({
      success: true,
      message: "Products fetched successfully",
      data: [],
      meta: {
        currentPage: query.page,
        itemsPerPage: query.limit,
        totalItems: 0,
        totalPages: 0,
      },
    });
  },
);

export default router;

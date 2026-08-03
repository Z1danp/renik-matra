export interface Category {
  id: number;
  name: string;
  slug: string;
}

export interface ProductBase {
  id: string;
  name: string;
  slug: string;
  brand: string;
  category: Category;
  createdAt: string;
}

export interface Product extends ProductBase {
  startingPrice: number;
  totalStock: number;
}

export interface PaginationMeta {
  currentPage: number;
  itemsPerPage: number;
  totalItems: number;
  totalPages: number;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  meta?: PaginationMeta;
}

export type ProductSort = "latest" | "price-asc" | "price-desc";

export interface ProductListQuery {
  page: number;
  limit: number;
  search: string | null;
  category: string | null;
  sortBy: ProductSort;
}

export type ProductListErrorResponse = {
  success: false;
  message: string;
  errors: Record<string, string[] | undefined>;
};

export type ProductListResponse = ApiResponse<Product[]>;

// detail product

export interface GhsHazard {
  code: string;
  name: string;
}

export interface ChemicalAttributes {
  type: "CHEMICAL";
  casNumber: string;
  iupacName: string | null;
  formula: string | null;
  ghsHazards: GhsHazard[];
}

export interface GlasswareAttributes {
  type: "GLASSWARE";
  material: string;
  glassClass: string | null;
  isAutoclavable: boolean;
}

export interface InstrumentPartAttributes {
  type: "INSTRUMENT_PART";
  instrumentType: string;
  oemPartNumber: string | null;
}

export type ProductAttributes =
  | ChemicalAttributes
  | GlasswareAttributes
  | InstrumentPartAttributes;

export interface ProductVariant {
  id: string;
  sku: string;
  grade: string | null;
  packagingSize: number | null;
  unit: string | null;
  price: number;
  stock: number;
}

export interface ProductDetail extends ProductBase {
  description: string | null;
  attributes: ProductAttributes;
  variants: ProductVariant[];
}

export type ProductDetailResponse = ApiResponse<ProductDetail>;

import { ApiResponse } from "./product";

export interface CartItem {
  itemId: string;
  productVariantId: string;
  productName: string;
  productSlug: string;
  variantSku: string;
  variantDetails: string;
  price: number;
  quantity: number;
  subtotal: number;
  availableStock: number;
}

export interface Cart {
  cartId: string;
  items: CartItem[];
  totalItems: number;
  grandTotal: number;
}

export type CartResponse = ApiResponse<Cart>;

export interface AddToCartRequest {
  productVariantId: string;
  quantity: number;
}

export interface AddToCartItem {
  itemId: string;
  quantity: number;
}

export type AddToCartResponse = ApiResponse<AddToCartItem>;

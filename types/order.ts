import { ApiResponse } from "./product";

export type OrderStatus =
  | "PENDING_PAYMENT"
  | "PAID"
  | "PROCESSING"
  | "SHIPPED"
  | "COMPLETED"
  | "CANCELLED"
  | "EXPIRED";

export interface CheckoutRequest {
  addressId: string;
}

export interface CheckoutPayment {
  paymentId: string;
  paymentUrl: string;
  expiredAt: string;
}

export interface CheckoutOrder {
  orderId: string;
  orderNumber: string;
  status: OrderStatus;
  totalAmount: number;
  payment: CheckoutPayment;
}

export type CheckoutResponse = ApiResponse<CheckoutOrder>;

// order list
export interface OrderListItem {
  orderId: string;
  orderNumber: string;
  status: OrderStatus;
  totalAmount: number;
  totalItems: number;
  createdAt: string;
}

export type OrderListResponse = ApiResponse<OrderListItem[]>;

// order detail
export interface ShippingAddress {
  recipientName: string;
  recipientPhone: string;
  institutionName: string | null;
  fullAddress: string;
  city: string;
  province: string;
  postalCode: string;
}

export interface OrderItem {
  itemId: string;
  productName: string;
  variantSku: string;
  variantDetails: string;
  priceAtPurchase: number;
  quantity: number;
  subtotal: number;
}

export interface OrderPayment {
  status: string;
  paymentType: string | null;
  paidAt: string | null;
}

export interface OrderDetail {
  orderId: string;
  orderNumber: string;
  status: OrderStatus;
  totalAmount: number;
  createdAt: string;
  shippingAddress: ShippingAddress;
  items: OrderItem[];
  payment: OrderPayment;
}

export type OrderDetailResponse = ApiResponse<OrderDetail>;

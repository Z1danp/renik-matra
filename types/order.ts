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

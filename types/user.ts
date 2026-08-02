export type UserRole = "BUYER" | "ADMIN";

export interface User {
  id: string; // UUID
  email: string;
  fullName: string;
  phoneNumber: string | null;
  role: UserRole;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

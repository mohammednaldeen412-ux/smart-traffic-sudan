export interface User {
  id: string;
  name: string;
  phone: string;
  email: string;
  accountNumber: string;
  iban: string;
  cardNumber: string;
  cardExpiry: string;
  cardCvv: string;
  balance: number;
  currency: string;
  pin: string; // 4-digit PIN e.g. "1234"
  avatar?: string;
  role: 'personal' | 'merchant';
}

export type TransactionType = 'transfer_out' | 'transfer_in' | 'payment_gateway' | 'deposit';
export type TransactionStatus = 'success' | 'failed' | 'pending';

export interface Transaction {
  id: string;
  type: TransactionType;
  amount: number;
  currency: string;
  title: string;
  description?: string;
  recipientName?: string;
  recipientAccount?: string;
  senderName?: string;
  senderAccount?: string;
  merchantName?: string;
  orderId?: string;
  status: TransactionStatus;
  timestamp: string;
  fee: number;
  referenceNumber: string;
  callbackUrl?: string;
}

export interface PaymentRequest {
  merchant: string;
  amount: number;
  currency: string;
  order_id: string;
  description?: string;
  callback_url?: string;
  customer_name?: string;
  items?: {
    name: string;
    quantity: number;
    price: number;
  }[];
}

export interface Beneficiary {
  id: string;
  name: string;
  accountNumber: string;
  phone: string;
  bankName: string;
  avatarColor: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  errorCode?: string;
}

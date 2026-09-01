import type { PaymentRequest, Transaction, ApiResponse } from '../types';
import { storageService } from './storageService';
import { mockRequest } from './apiClient';

export interface ProcessPaymentPayload {
  paymentRequest: PaymentRequest;
  pin: string;
}

export interface PaymentExecutionResult {
  transaction: Transaction;
  redirectUrl?: string;
  callbackPayload: {
    status: 'PAID' | 'FAILED';
    transaction_id: string;
    order_id: string;
    amount: number;
    currency: string;
    paid_at: string;
    reference: string;
    signature: string;
  };
}

export const gatewayService = {
  parseFromSearchParams(searchParams: URLSearchParams): PaymentRequest | null {
    const amountStr = searchParams.get('amount');
    const merchant = searchParams.get('merchant') || searchParams.get('merchant_name');
    const order_id = searchParams.get('order_id') || searchParams.get('orderId');

    if (!amountStr && !merchant && !order_id) {
      return null;
    }

    const amount = parseFloat(amountStr || '0');
    const currency = searchParams.get('currency') || 'SDG';
    const description = searchParams.get('description') || searchParams.get('desc') || 'سداد طلب من المتجر';
    const callback_url = searchParams.get('callback_url') || searchParams.get('callbackUrl') || searchParams.get('redirect_url') || '';
    const customer_name = searchParams.get('customer_name') || searchParams.get('customer') || '';

    let items;
    const itemsRaw = searchParams.get('items');
    if (itemsRaw) {
      try {
        items = JSON.parse(itemsRaw);
      } catch {
        items = undefined;
      }
    }

    return {
      merchant: merchant || 'متجر إلكتروني غير محدد',
      amount: isNaN(amount) ? 0 : amount,
      currency,
      order_id: order_id || `ORD-${Date.now().toString().slice(-6)}`,
      description,
      callback_url,
      customer_name,
      items,
    };
  },

  async processPayment(payload: ProcessPaymentPayload): Promise<ApiResponse<PaymentExecutionResult>> {
    const { paymentRequest, pin } = payload;
    const user = storageService.getCurrentUser();

    // Validate PIN
    if (user.pin !== pin) {
      return mockRequest(null as unknown as PaymentExecutionResult, 400, true, 'رمز الـ PIN غير صحيح');
    }

    // Validate Balance
    if (user.balance < paymentRequest.amount) {
      return mockRequest(null as unknown as PaymentExecutionResult, 400, true, 'رصيدك الحالي غير كافٍ لإتمام عملية الدفع');
    }

    if (paymentRequest.amount <= 0) {
      return mockRequest(null as unknown as PaymentExecutionResult, 200, true, 'مبلغ العملية غير صالح');
    }

    // Deduct user balance
    const newBalance = user.balance - paymentRequest.amount;
    storageService.updateCurrentUser({ balance: newBalance });

    const txId = `TXN-GW-${Math.floor(100000 + Math.random() * 900000)}`;
    const ref = `REF-GW-${new Date().getFullYear()}-${Math.floor(10000 + Math.random() * 90000)}`;
    const paidAt = new Date().toISOString();

    const transaction: Transaction = {
      id: txId,
      type: 'payment_gateway',
      amount: paymentRequest.amount,
      currency: paymentRequest.currency || user.currency,
      title: `دفع إلى ${paymentRequest.merchant}`,
      description: paymentRequest.description || `طلب رقم #${paymentRequest.order_id}`,
      merchantName: paymentRequest.merchant,
      orderId: paymentRequest.order_id,
      senderName: user.name,
      senderAccount: user.accountNumber,
      status: 'success',
      timestamp: paidAt,
      fee: 0,
      referenceNumber: ref,
      callbackUrl: paymentRequest.callback_url,
    };

    storageService.addTransaction(transaction);

    // Build simulated signature and response
    const signature = `mock_sig_${Math.random().toString(36).substring(2, 15)}_${Date.now()}`;
    const callbackPayload = {
      status: 'PAID' as const,
      transaction_id: txId,
      order_id: paymentRequest.order_id,
      amount: paymentRequest.amount,
      currency: paymentRequest.currency || 'SDG',
      paid_at: paidAt,
      reference: ref,
      signature,
    };

    let redirectUrl = '';
    if (paymentRequest.callback_url) {
      try {
        const urlObj = new URL(paymentRequest.callback_url);
        urlObj.searchParams.set('status', 'success');
        urlObj.searchParams.set('txn_id', txId);
        urlObj.searchParams.set('order_id', paymentRequest.order_id);
        urlObj.searchParams.set('amount', paymentRequest.amount.toString());
        urlObj.searchParams.set('reference', ref);
        urlObj.searchParams.set('signature', signature);
        redirectUrl = urlObj.toString();
      } catch {
        redirectUrl = `${paymentRequest.callback_url}?status=success&txn_id=${txId}&order_id=${paymentRequest.order_id}`;
      }
    }

    return mockRequest({
      transaction,
      redirectUrl,
      callbackPayload,
    }, 600);
  },

  generatePaymentLink(req: PaymentRequest, baseUrl: string = window.location.origin): string {
    const url = new URL(`${baseUrl}/pay`);
    url.searchParams.set('merchant', req.merchant);
    url.searchParams.set('amount', req.amount.toString());
    url.searchParams.set('currency', req.currency || 'SDG');
    url.searchParams.set('order_id', req.order_id);
    if (req.description) url.searchParams.set('description', req.description);
    if (req.callback_url) url.searchParams.set('callback_url', req.callback_url);
    if (req.customer_name) url.searchParams.set('customer_name', req.customer_name);
    return url.toString();
  }
};

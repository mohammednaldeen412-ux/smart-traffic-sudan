import type { Transaction, ApiResponse, Beneficiary } from '../types';
import { storageService } from './storageService';
import { mockRequest } from './apiClient';
import { doc, getDoc } from 'firebase/firestore';
import { db } from './firebaseConfig';

export interface TransferPayload {
  recipientAccount: string;
  recipientName?: string;
  amount: number;
  note?: string;
  pin: string;
}

export const walletService = {
  async getTransactions(): Promise<ApiResponse<Transaction[]>> {
    const txs = storageService.getTransactions();
    return mockRequest(txs, 200);
  },

  async getTransactionById(id: string): Promise<ApiResponse<Transaction>> {
    const tx = storageService.getTransactionById(id);
    if (tx) {
      return mockRequest(tx, 150);
    }

    // البحث في Firestore
    try {
      const snap = await getDoc(doc(db, 'bank_transactions', id));
      if (snap.exists()) {
        const data = snap.data();
        const firestoreTx: Transaction = {
          id: snap.id,
          type: data.type || 'payment_gateway',
          amount: Number(data.amount || 0),
          currency: data.currency || 'SDG',
          title: data.title || 'معاملة بنكية',
          description: data.description || '',
          recipientName: data.recipientName,
          recipientAccount: data.recipientAccount,
          senderName: data.senderName,
          senderAccount: data.senderAccount,
          merchantName: data.merchantName,
          orderId: data.orderId,
          status: data.status || 'success',
          timestamp: data.timestamp || new Date().toISOString(),
          fee: Number(data.fee || 0),
          referenceNumber: data.referenceNumber || snap.id,
          callbackUrl: data.callbackUrl
        };
        return mockRequest(firestoreTx, 150);
      }
    } catch (e) {
      console.error('[walletService] Error fetching from Firestore:', e);
    }

    return mockRequest(null as unknown as Transaction, 200, true, 'لم يتم العثور على العملية المطلوبة');
  },

  async sendTransfer(payload: TransferPayload): Promise<ApiResponse<Transaction>> {
    const user = storageService.getCurrentUser();
    
    // Check PIN
    if (user.pin !== payload.pin) {
      return mockRequest(null as unknown as Transaction, 300, true, 'رمز الـ PIN غير صحيح');
    }

    const fee = 100; // 100 SDG mock transfer fee
    const totalDeduction = payload.amount + fee;

    if (user.balance < totalDeduction) {
      return mockRequest(null as unknown as Transaction, 300, true, 'الرصيد المتاح غير كافٍ لإتمام التحويل والرسوم');
    }

    if (payload.amount <= 0) {
      return mockRequest(null as unknown as Transaction, 200, true, 'يرجى إدخال مبلغ صحيح');
    }

    // Deduct balance
    const newBalance = user.balance - totalDeduction;
    storageService.updateCurrentUser({ balance: newBalance });

    const newTx: Transaction = {
      id: `TXN-${Math.floor(100000 + Math.random() * 900000)}`,
      type: 'transfer_out',
      amount: payload.amount,
      currency: user.currency,
      title: `تحويل إلى ${payload.recipientName || 'حساب رقم ' + payload.recipientAccount}`,
      description: payload.note || 'تحويل فوري بين الحسابات',
      recipientName: payload.recipientName || 'مستلم بنكك',
      recipientAccount: payload.recipientAccount,
      senderName: user.name,
      senderAccount: user.accountNumber,
      status: 'success',
      timestamp: new Date().toISOString(),
      fee: fee,
      referenceNumber: `REF-${new Date().getFullYear()}-${Math.floor(10000 + Math.random() * 90000)}`,
    };

    storageService.addTransaction(newTx);
    return mockRequest(newTx, 600);
  },

  async depositFunds(amount: number): Promise<ApiResponse<number>> {
    if (amount <= 0) {
      return mockRequest(0, 100, true, 'المبلغ غير صحيح');
    }
    const user = storageService.getCurrentUser();
    const newBalance = user.balance + amount;
    storageService.updateCurrentUser({ balance: newBalance });

    const newTx: Transaction = {
      id: `TXN-${Math.floor(100000 + Math.random() * 900000)}`,
      type: 'deposit',
      amount: amount,
      currency: user.currency,
      title: 'شحن رصيد تجريبي',
      description: 'إيداع نقدي وهمي لغرض الاختبار',
      senderName: 'بوابة الشحن السريع',
      status: 'success',
      timestamp: new Date().toISOString(),
      fee: 0,
      referenceNumber: `REF-${new Date().getFullYear()}-${Math.floor(10000 + Math.random() * 90000)}`,
    };

    storageService.addTransaction(newTx);
    return mockRequest(newBalance, 300);
  },

  async getBeneficiaries(): Promise<ApiResponse<Beneficiary[]>> {
    const list = storageService.getBeneficiaries();
    return mockRequest(list, 100);
  }
};

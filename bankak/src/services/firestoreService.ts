import {
  collection,
  doc,
  getDocs,
  setDoc,
  updateDoc,
  onSnapshot,
  serverTimestamp
} from "firebase/firestore";
import { db } from "./firebaseConfig";
import type { User, Transaction } from "../types";
import { DEFAULT_USERS, DEFAULT_TRANSACTIONS } from "./mockData";

export const firestoreService = {
  // --- بذر الحسابات الافتراضية ---
  async seedInitialData(): Promise<void> {
    try {
      const snap = await getDocs(collection(db, "bank_accounts"));
      if (snap.empty) {
        for (const user of DEFAULT_USERS) {
          await setDoc(doc(db, "bank_accounts", user.id), {
            ...user,
            createdAt: serverTimestamp()
          });
        }
        for (const tx of DEFAULT_TRANSACTIONS) {
          await setDoc(doc(db, "bank_transactions", tx.id), {
            ...tx,
            createdAt: serverTimestamp()
          });
        }
      }
    } catch (e) {
      console.error("[Firestore] Error seeding data:", e);
    }
  },

  // --- جلب كل الحسابات البنكية ---
  async getBankAccounts(): Promise<User[]> {
    try {
      const snap = await getDocs(collection(db, "bank_accounts"));
      if (snap.empty) {
        await this.seedInitialData();
        return DEFAULT_USERS;
      }
      return snap.docs.map(d => ({ id: d.id, ...d.data() } as User));
    } catch (e) {
      console.error("[Firestore] Error getting accounts:", e);
      return DEFAULT_USERS;
    }
  },

  // --- الاستماع اللحظي لتغير رصيد وبيانات المستخدم ---
  subscribeToUser(userId: string, onUpdate: (user: User) => void): () => void {
    const userDocRef = doc(db, "bank_accounts", userId);
    return onSnapshot(userDocRef, (snap) => {
      if (snap.exists()) {
        onUpdate({ id: snap.id, ...snap.data() } as User);
      }
    }, (err) => {
      console.error("[Firestore] User subscription error:", err);
    });
  },

  // --- الاستماع اللحظي لسجل المعاملات ---
  subscribeToTransactions(onUpdate: (transactions: Transaction[]) => void): () => void {
    const txCol = collection(db, "bank_transactions");
    return onSnapshot(txCol, (snap) => {
      const list: Transaction[] = snap.docs.map(d => {
        const data = d.data();
        return {
          id: d.id,
          type: data.type || "payment_gateway",
          amount: Number(data.amount || 0),
          currency: data.currency || "SDG",
          title: data.title || "معاملة بنكية",
          description: data.description || "",
          recipientName: data.recipientName,
          recipientAccount: data.recipientAccount,
          senderName: data.senderName,
          senderAccount: data.senderAccount,
          merchantName: data.merchantName,
          orderId: data.orderId,
          status: data.status || "success",
          timestamp: data.timestamp || new Date().toISOString(),
          fee: Number(data.fee || 0),
          referenceNumber: data.referenceNumber || d.id,
          callbackUrl: data.callbackUrl
        };
      });

      // فرز حسب الأحدث
      list.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
      onUpdate(list);
    }, (err) => {
      console.error("[Firestore] Transactions subscription error:", err);
    });
  },

  // --- إضافة معاملة جديدة ---
  async addTransaction(tx: Transaction): Promise<void> {
    try {
      await setDoc(doc(db, "bank_transactions", tx.id), {
        ...tx,
        createdAt: serverTimestamp()
      });
    } catch (e) {
      console.error("[Firestore] Error adding transaction:", e);
    }
  },

  // --- تحديث الرصيد ---
  async updateUserBalance(userId: string, newBalance: number): Promise<void> {
    try {
      await updateDoc(doc(db, "bank_accounts", userId), {
        balance: newBalance,
        updatedAt: serverTimestamp()
      });
    } catch (e) {
      console.error("[Firestore] Error updating balance:", e);
    }
  }
};

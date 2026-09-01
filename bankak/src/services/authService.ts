import type { User, ApiResponse } from '../types';
import { storageService } from './storageService';
import { mockRequest } from './apiClient';
import { doc, getDoc, updateDoc, collection, getDocs, serverTimestamp } from 'firebase/firestore';
import { db } from './firebaseConfig';

export const authService = {
  async getCurrentUser(): Promise<ApiResponse<User>> {
    const user = storageService.getCurrentUser();
    return mockRequest(user, 150);
  },

  async login(phoneOrAccount: string, pin: string): Promise<ApiResponse<User>> {
    const cleanInput = phoneOrAccount.trim();

    // 1. فحص في التخزين المحلي أولاً
    let users = storageService.getUsers();
    let matched = users.find(
      u => (u.phone === cleanInput || u.accountNumber === cleanInput || u.email === cleanInput)
    );

    // 2. إذا لم يوجد أو للتحقق من أحدث PIN، فحص في Firestore
    try {
      const snap = await getDocs(collection(db, 'bank_accounts'));
      if (!snap.empty) {
        const fsUsers = snap.docs.map(d => ({ id: d.id, ...d.data() } as User));
        storageService.saveUsers(fsUsers);
        const fsMatched = fsUsers.find(
          u => (u.phone === cleanInput || u.accountNumber === cleanInput || u.email === cleanInput)
        );
        if (fsMatched) {
          matched = fsMatched;
        }
      }
    } catch (e) {
      console.error('[authService] Error fetching accounts from Firestore:', e);
    }

    if (!matched) {
      return mockRequest(null as unknown as User, 400, true, 'رقم الهاتف أو الحساب غير مسجل في النظام البنكي');
    }

    if (matched.pin !== pin) {
      return mockRequest(null as unknown as User, 400, true, 'رمز الـ PIN غير صحيح، يرجى المحاولة مرة أخرى');
    }

    storageService.setCurrentUserId(matched.id);
    return mockRequest(matched, 350);
  },

  async quickLoginAs(userId: string): Promise<ApiResponse<User>> {
    let users = storageService.getUsers();
    let user = users.find(u => u.id === userId);

    if (!user) {
      try {
        const snap = await getDoc(doc(db, 'bank_accounts', userId));
        if (snap.exists()) {
          user = { id: snap.id, ...snap.data() } as User;
        }
      } catch (_) {}
    }

    if (!user) {
      return mockRequest(null as unknown as User, 200, true, 'المستخدم غير موجود');
    }
    storageService.setCurrentUserId(user.id);
    return mockRequest(user, 200);
  },

  async verifyPin(pin: string): Promise<boolean> {
    const user = storageService.getCurrentUser();
    if (!user) return false;
    try {
      const snap = await getDoc(doc(db, 'bank_accounts', user.id));
      if (snap.exists()) {
        const freshPin = snap.data().pin;
        return freshPin === pin;
      }
    } catch (_) {}
    return user.pin === pin;
  },

  async updatePin(newPin: string): Promise<ApiResponse<boolean>> {
    if (newPin.length !== 4 || !/^\d{4}$/.test(newPin)) {
      return mockRequest(false, 100, true, 'يجب أن يتكون رمز الـ PIN من 4 أرقام');
    }

    const user = storageService.getCurrentUser();
    storageService.updateCurrentUser({ pin: newPin });

    // تحديث مباشر في Firestore
    try {
      if (user?.id) {
        await updateDoc(doc(db, 'bank_accounts', user.id), {
          pin: newPin,
          updatedAt: serverTimestamp()
        });
      }
    } catch (e) {
      console.error('[authService] Error updating PIN in Firestore:', e);
    }

    return mockRequest(true, 300);
  },

  logout(): void {
    // Keep user in storage
  }
};

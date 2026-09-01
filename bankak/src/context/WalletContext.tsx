import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import type { Transaction, Beneficiary } from '../types';
import type { TransferPayload } from '../services/walletService';
import { walletService } from '../services/walletService';
import { firestoreService } from '../services/firestoreService';
import { useAuth } from './AuthContext';

interface WalletContextType {
  transactions: Transaction[];
  beneficiaries: Beneficiary[];
  isBalanceHidden: boolean;
  toggleBalanceHidden: () => void;
  isLoading: boolean;
  refreshTransactions: () => Promise<void>;
  sendTransfer: (payload: TransferPayload) => Promise<{ success: boolean; transaction?: Transaction; message?: string }>;
  deposit: (amount: number) => Promise<{ success: boolean; message?: string }>;
}

const WalletContext = createContext<WalletContextType | undefined>(undefined);

export const WalletProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { refreshUser } = useAuth();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [beneficiaries, setBeneficiaries] = useState<Beneficiary[]>([]);
  const [isBalanceHidden, setIsBalanceHidden] = useState<boolean>(() => {
    return localStorage.getItem('bankak_hide_balance') === 'true';
  });
  const [isLoading, setIsLoading] = useState(false);

  const toggleBalanceHidden = () => {
    setIsBalanceHidden(prev => {
      const next = !prev;
      localStorage.setItem('bankak_hide_balance', String(next));
      return next;
    });
  };

  const refreshTransactions = useCallback(async () => {
    setIsLoading(true);
    const txRes = await walletService.getTransactions();
    if (txRes.success && txRes.data) {
      setTransactions(txRes.data);
    }
    const benRes = await walletService.getBeneficiaries();
    if (benRes.success && benRes.data) {
      setBeneficiaries(benRes.data);
    }
    setIsLoading(false);
  }, []);

  // الاستماع اللحظي للمعاملات من Firestore (تشمل عمليات الدفع من تطبيق المرور)
  useEffect(() => {
    refreshTransactions();
    const unsubscribe = firestoreService.subscribeToTransactions((fsTxns) => {
      if (fsTxns && fsTxns.length > 0) {
        setTransactions(fsTxns);
      }
    });
    return () => unsubscribe();
  }, [refreshTransactions]);

  const sendTransfer = async (payload: TransferPayload) => {
    setIsLoading(true);
    const res = await walletService.sendTransfer(payload);
    setIsLoading(false);
    if (res.success && res.data) {
      refreshUser();
      await refreshTransactions();
      return { success: true, transaction: res.data };
    }
    return { success: false, message: res.message || 'فشلت عملية التحويل' };
  };

  const deposit = async (amount: number) => {
    setIsLoading(true);
    const res = await walletService.depositFunds(amount);
    setIsLoading(false);
    if (res.success) {
      refreshUser();
      await refreshTransactions();
      return { success: true };
    }
    return { success: false, message: res.message || 'فشلت عملية الشحن' };
  };

  return (
    <WalletContext.Provider
      value={{
        transactions,
        beneficiaries,
        isBalanceHidden,
        toggleBalanceHidden,
        isLoading,
        refreshTransactions,
        sendTransfer,
        deposit,
      }}
    >
      {children}
    </WalletContext.Provider>
  );
};

export const useWallet = () => {
  const context = useContext(WalletContext);
  if (!context) {
    throw new Error('useWallet must be used within a WalletProvider');
  }
  return context;
};

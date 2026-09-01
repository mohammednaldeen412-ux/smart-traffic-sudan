import React, { createContext, useContext, useState, useEffect } from 'react';
import type { User } from '../types';
import { authService } from '../services/authService';
import { storageService } from '../services/storageService';
import { firestoreService } from '../services/firestoreService';

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (phoneOrAccount: string, pin: string) => Promise<{ success: boolean; message?: string }>;
  quickSwitch: (userId: string) => Promise<void>;
  updatePin: (newPin: string) => Promise<{ success: boolean; message?: string }>;
  logout: () => void;
  refreshUser: () => void;
  resetAll: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const refreshUser = () => {
    const currentUser = storageService.getCurrentUser();
    setUser(currentUser);
  };

  useEffect(() => {
    refreshUser();
    setIsLoading(false);

    // بذر البيانات إذا لزم
    firestoreService.seedInitialData();
  }, []);

  // الاستماع اللحظي لتحديثات رصيد المستخدم من Firestore
  useEffect(() => {
    if (!user?.id) return;
    const unsub = firestoreService.subscribeToUser(user.id, (fsUser) => {
      if (fsUser) {
        setUser(prev => ({ ...prev, ...fsUser }));
        storageService.updateCurrentUser(fsUser);
      }
    });
    return () => unsub();
  }, [user?.id]);

  const login = async (phoneOrAccount: string, pin: string) => {
    setIsLoading(true);
    const res = await authService.login(phoneOrAccount, pin);
    setIsLoading(false);
    if (res.success && res.data) {
      setUser(res.data);
      return { success: true };
    }
    return { success: false, message: res.message || 'فشل تسجيل الدخول' };
  };

  const quickSwitch = async (userId: string) => {
    setIsLoading(true);
    const res = await authService.quickLoginAs(userId);
    setIsLoading(false);
    if (res.success && res.data) {
      setUser(res.data);
    }
  };

  const updatePin = async (newPin: string) => {
    const res = await authService.updatePin(newPin);
    if (res.success) {
      refreshUser();
      return { success: true };
    }
    return { success: false, message: res.message };
  };

  const logout = () => {
    authService.logout();
    refreshUser();
  };

  const resetAll = () => {
    storageService.resetAllData();
    refreshUser();
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        isLoading,
        login,
        quickSwitch,
        updatePin,
        logout,
        refreshUser,
        resetAll,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

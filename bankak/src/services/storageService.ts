import type { User, Transaction, Beneficiary } from '../types';
import { DEFAULT_USERS, DEFAULT_TRANSACTIONS, DEFAULT_BENEFICIARIES } from './mockData';

const USERS_KEY = 'bankak_users_v1';
const CURRENT_USER_ID_KEY = 'bankak_current_user_id';
const TRANSACTIONS_KEY = 'bankak_transactions_v1';
const BENEFICIARIES_KEY = 'bankak_beneficiaries_v1';

export const storageService = {
  getUsers(): User[] {
    const raw = localStorage.getItem(USERS_KEY);
    if (!raw) {
      this.saveUsers(DEFAULT_USERS);
      return DEFAULT_USERS;
    }
    try {
      return JSON.parse(raw);
    } catch {
      return DEFAULT_USERS;
    }
  },

  saveUsers(users: User[]): void {
    localStorage.setItem(USERS_KEY, JSON.stringify(users));
  },

  getCurrentUser(): User {
    const users = this.getUsers();
    const currentId = localStorage.getItem(CURRENT_USER_ID_KEY);
    if (currentId) {
      const found = users.find(u => u.id === currentId);
      if (found) return found;
    }
    const defaultUser = users[0] || DEFAULT_USERS[0];
    localStorage.setItem(CURRENT_USER_ID_KEY, defaultUser.id);
    return defaultUser;
  },

  setCurrentUserId(id: string): void {
    localStorage.setItem(CURRENT_USER_ID_KEY, id);
  },

  updateCurrentUser(updated: Partial<User>): User {
    const users = this.getUsers();
    const current = this.getCurrentUser();
    const index = users.findIndex(u => u.id === current.id);
    if (index !== -1) {
      users[index] = { ...users[index], ...updated };
      this.saveUsers(users);
      return users[index];
    }
    return current;
  },

  getTransactions(): Transaction[] {
    const raw = localStorage.getItem(TRANSACTIONS_KEY);
    if (!raw) {
      this.saveTransactions(DEFAULT_TRANSACTIONS);
      return DEFAULT_TRANSACTIONS;
    }
    try {
      return JSON.parse(raw);
    } catch {
      return DEFAULT_TRANSACTIONS;
    }
  },

  saveTransactions(transactions: Transaction[]): void {
    localStorage.setItem(TRANSACTIONS_KEY, JSON.stringify(transactions));
  },

  addTransaction(tx: Transaction): void {
    const all = this.getTransactions();
    const updated = [tx, ...all];
    this.saveTransactions(updated);
  },

  getTransactionById(id: string): Transaction | undefined {
    return this.getTransactions().find(t => t.id === id);
  },

  getBeneficiaries(): Beneficiary[] {
    const raw = localStorage.getItem(BENEFICIARIES_KEY);
    if (!raw) {
      localStorage.setItem(BENEFICIARIES_KEY, JSON.stringify(DEFAULT_BENEFICIARIES));
      return DEFAULT_BENEFICIARIES;
    }
    try {
      return JSON.parse(raw);
    } catch {
      return DEFAULT_BENEFICIARIES;
    }
  },

  addBeneficiary(beneficiary: Beneficiary): void {
    const all = this.getBeneficiaries();
    const updated = [beneficiary, ...all];
    localStorage.setItem(BENEFICIARIES_KEY, JSON.stringify(updated));
  },

  resetAllData(): void {
    localStorage.removeItem(USERS_KEY);
    localStorage.removeItem(CURRENT_USER_ID_KEY);
    localStorage.removeItem(TRANSACTIONS_KEY);
    localStorage.removeItem(BENEFICIARIES_KEY);
    this.saveUsers(DEFAULT_USERS);
    this.saveTransactions(DEFAULT_TRANSACTIONS);
    this.setCurrentUserId(DEFAULT_USERS[0].id);
  }
};

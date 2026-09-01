import React, { useState } from 'react';
import { Eye, EyeOff, Copy, Check, Wifi, Landmark } from 'lucide-react';
import type { User } from '../types';
import { formatCurrency } from '../utils/formatters';

interface BankCardProps {
  user: User;
  isBalanceHidden: boolean;
  onToggleBalance: () => void;
}

export const BankCard: React.FC<BankCardProps> = ({
  user,
  isBalanceHidden,
  onToggleBalance,
}) => {
  const [copiedAcc, setCopiedAcc] = useState(false);

  const copyAccountNumber = () => {
    navigator.clipboard.writeText(user.accountNumber);
    setCopiedAcc(true);
    setTimeout(() => setCopiedAcc(false), 2000);
  };

  return (
    <div className="relative overflow-hidden rounded-3xl p-6 text-white shadow-2xl transition-all duration-300 hover:shadow-emerald-900/30 bg-gradient-to-tr from-slate-900 via-emerald-950 to-teal-900 border border-emerald-500/30">
      
      {/* Background glowing gradients */}
      <div className="absolute -top-24 -left-24 w-48 h-48 bg-emerald-500/20 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-24 -right-24 w-48 h-48 bg-teal-400/10 rounded-full blur-3xl pointer-events-none" />

      {/* Top row: Brand & Contactless Icon */}
      <div className="flex items-center justify-between mb-5 relative z-10">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-xl bg-emerald-500/20 border border-emerald-400/40 flex items-center justify-center text-emerald-300">
            <Landmark className="w-4 h-4" />
          </div>
          <div>
            <span className="font-extrabold tracking-wider text-sm">بنكك</span>
            <span className="text-[10px] text-emerald-300/80 block">الحساب الجاري التجريبي</span>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <Wifi className="w-5 h-5 text-emerald-300/70 rotate-90" />
          <span className="text-xs uppercase tracking-widest px-2 py-0.5 rounded-md bg-emerald-500/20 text-emerald-200 border border-emerald-400/20 font-mono">
            MOCK
          </span>
        </div>
      </div>

      {/* Balance Section */}
      <div className="mb-6 relative z-10">
        <div className="flex items-center gap-2 text-xs text-emerald-200/80 mb-1">
          <span>الرصيد المتاح</span>
          <button
            onClick={onToggleBalance}
            className="p-1 rounded-full hover:bg-white/10 transition-colors text-emerald-300"
            title={isBalanceHidden ? 'إظهار الرصيد' : 'إخفاء الرصيد'}
          >
            {isBalanceHidden ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
          </button>
        </div>
        <div className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white flex items-baseline gap-2">
          {isBalanceHidden ? (
            <span className="tracking-widest font-mono text-2xl">••••••••</span>
          ) : (
            <span>{formatCurrency(user.balance, user.currency)}</span>
          )}
        </div>
      </div>

      {/* Card Chip & Account Row */}
      <div className="flex items-center justify-between mb-4 relative z-10">
        {/* EMV Chip Simulation */}
        <div className="w-11 h-8 rounded-md bg-gradient-to-tr from-amber-300 via-yellow-400 to-amber-200 border border-amber-600/60 shadow-sm flex items-center justify-center">
          <div className="w-7 h-5 border border-amber-800/40 rounded-sm opacity-80" />
        </div>

        {/* Card Number */}
        <div className="font-mono text-sm tracking-wider text-slate-200">
          {user.cardNumber}
        </div>
      </div>

      {/* Bottom details: Name, Account Number, Expiry */}
      <div className="flex items-end justify-between pt-3 border-t border-emerald-500/20 relative z-10 text-xs">
        <div>
          <span className="text-[10px] text-emerald-200/70 block">صاحب الحساب</span>
          <span className="font-bold text-white tracking-wide">{user.name}</span>
        </div>

        <div className="text-left">
          <span className="text-[10px] text-emerald-200/70 block">رقم الحساب</span>
          <button
            onClick={copyAccountNumber}
            className="flex items-center gap-1 font-mono font-bold text-slate-200 hover:text-emerald-300 transition-colors"
            title="نسخ رقم الحساب"
          >
            <span>{user.accountNumber}</span>
            {copiedAcc ? <Check className="w-3 h-3 text-emerald-400" /> : <Copy className="w-3 h-3" />}
          </button>
        </div>
      </div>

    </div>
  );
};

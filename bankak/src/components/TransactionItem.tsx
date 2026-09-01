import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowUpRight, ArrowDownLeft, ShoppingBag, ArrowDownRight, CheckCircle2, XCircle, Clock } from 'lucide-react';
import type { Transaction } from '../types';
import { formatTimeAgo } from '../utils/formatters';

interface TransactionItemProps {
  transaction: Transaction;
}

export const TransactionItem: React.FC<TransactionItemProps> = ({ transaction }) => {
  const navigate = useNavigate();

  const getIconAndColor = () => {
    switch (transaction.type) {
      case 'deposit':
        return {
          icon: ArrowDownLeft,
          bgColor: 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400',
          amountColor: 'text-emerald-400',
          prefix: '+',
        };
      case 'transfer_in':
        return {
          icon: ArrowDownRight,
          bgColor: 'bg-teal-500/10 border-teal-500/20 text-teal-400',
          amountColor: 'text-teal-400',
          prefix: '+',
        };
      case 'payment_gateway':
        return {
          icon: ShoppingBag,
          bgColor: 'bg-blue-500/10 border-blue-500/20 text-blue-400',
          amountColor: 'text-slate-100',
          prefix: '-',
        };
      case 'transfer_out':
      default:
        return {
          icon: ArrowUpRight,
          bgColor: 'bg-rose-500/10 border-rose-500/20 text-rose-400',
          amountColor: 'text-rose-400',
          prefix: '-',
        };
    }
  };

  const { icon: Icon, bgColor, amountColor, prefix } = getIconAndColor();

  const getStatusBadge = () => {
    if (transaction.status === 'success') {
      return null;
    }
    if (transaction.status === 'failed') {
      return (
        <span className="flex items-center gap-1 text-[10px] text-rose-400 bg-rose-500/10 px-1.5 py-0.5 rounded-md border border-rose-500/20">
          <XCircle className="w-3 h-3" />
          فشلت
        </span>
      );
    }
    return (
      <span className="flex items-center gap-1 text-[10px] text-amber-400 bg-amber-500/10 px-1.5 py-0.5 rounded-md border border-amber-500/20">
        <Clock className="w-3 h-3" />
        قيد الانتظار
      </span>
    );
  };

  return (
    <div
      onClick={() => navigate(`/receipt/${transaction.id}`)}
      className="flex items-center justify-between p-3.5 rounded-2xl bg-slate-900/60 hover:bg-slate-800/80 border border-slate-800 hover:border-slate-700 transition-all cursor-pointer group"
    >
      <div className="flex items-center gap-3.5">
        <div className={`w-11 h-11 rounded-2xl border flex items-center justify-center shrink-0 transition-transform group-hover:scale-105 ${bgColor}`}>
          <Icon className="w-5 h-5" />
        </div>

        <div>
          <div className="flex items-center gap-2">
            <h4 className="text-sm font-semibold text-slate-100 group-hover:text-emerald-300 transition-colors">
              {transaction.title}
            </h4>
            {getStatusBadge()}
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-400 mt-0.5">
            <span>{formatTimeAgo(transaction.timestamp)}</span>
            {transaction.orderId && (
              <>
                <span>•</span>
                <span className="font-mono text-[11px] text-slate-500">#{transaction.orderId}</span>
              </>
            )}
          </div>
        </div>
      </div>

      <div className="text-left">
        <div className={`text-sm font-bold font-mono ${amountColor}`}>
          {prefix}{transaction.amount.toLocaleString('ar-SD')} <span className="text-xs font-sans text-slate-400">{transaction.currency}</span>
        </div>
        <div className="text-[11px] text-slate-500 flex items-center justify-end gap-1 mt-0.5">
          <CheckCircle2 className="w-3 h-3 text-emerald-500" />
          <span>مكتملة</span>
        </div>
      </div>
    </div>
  );
};

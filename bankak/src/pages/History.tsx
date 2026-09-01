import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  History as HistoryIcon, 
  Search, 
  ArrowRight,
  ListFilter
} from 'lucide-react';
import { useWallet } from '../context/WalletContext';
import { TransactionItem } from '../components/TransactionItem';
import type { TransactionType } from '../types';

export const History: React.FC = () => {
  const navigate = useNavigate();
  const { transactions } = useWallet();

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState<'all' | TransactionType>('all');

  const filteredTransactions = transactions.filter(tx => {
    // Filter by type
    if (selectedFilter !== 'all' && tx.type !== selectedFilter) {
      return false;
    }

    // Filter by search query
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const matchTitle = tx.title.toLowerCase().includes(q);
      const matchId = tx.id.toLowerCase().includes(q);
      const matchRef = tx.referenceNumber.toLowerCase().includes(q);
      const matchMerchant = tx.merchantName?.toLowerCase().includes(q);
      const matchRecipient = tx.recipientName?.toLowerCase().includes(q);
      const matchOrder = tx.orderId?.toLowerCase().includes(q);

      return matchTitle || matchId || matchRef || matchMerchant || matchRecipient || matchOrder;
    }

    return true;
  });

  const filterTabs = [
    { id: 'all', label: 'الكل', count: transactions.length },
    { id: 'transfer_out', label: 'تحويلات', count: transactions.filter(t => t.type === 'transfer_out').length },
    { id: 'payment_gateway', label: 'بوابة الدفع', count: transactions.filter(t => t.type === 'payment_gateway').length },
    { id: 'deposit', label: 'إيداعات', count: transactions.filter(t => t.type === 'deposit').length },
  ];

  return (
    <div className="space-y-6 pb-20 sm:pb-8 animate-fade-in">
      
      {/* Header */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/')}
          className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
        >
          <ArrowRight className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-xl font-bold text-white flex items-center gap-2">
            <HistoryIcon className="w-5 h-5 text-emerald-400" />
            سجل المعاملات والعمليات
          </h1>
          <p className="text-xs text-slate-400">تتبع جميع التحويلات والمدفوعات والإيداعات</p>
        </div>
      </div>

      {/* Search Input */}
      <div className="relative">
        <input
          type="text"
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder="ابحث بالاسم، رقم المعاملة، رقم الطلب، أو المتجر..."
          className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-sm placeholder-slate-500 focus:outline-none"
        />
        <Search className="w-5 h-5 text-slate-400 absolute top-3.5 right-3.5" />
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 scrollbar-none">
        {filterTabs.map(tab => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setSelectedFilter(tab.id as any)}
            className={`px-3.5 py-2 rounded-xl text-xs font-semibold shrink-0 transition-all flex items-center gap-1.5 ${
              selectedFilter === tab.id
                ? 'bg-emerald-500 text-slate-950 font-bold shadow-md shadow-emerald-500/20'
                : 'bg-slate-900/80 hover:bg-slate-800 text-slate-300 border border-slate-800'
            }`}
          >
            <span>{tab.label}</span>
            <span className={`text-[10px] px-1.5 py-0.2 rounded-full ${
              selectedFilter === tab.id ? 'bg-slate-950/30 text-slate-950' : 'bg-slate-800 text-slate-400'
            }`}>
              {tab.count}
            </span>
          </button>
        ))}
      </div>

      {/* Transactions List */}
      <div className="space-y-2.5">
        {filteredTransactions.length === 0 ? (
          <div className="text-center py-16 rounded-3xl bg-slate-900/40 border border-slate-800/80 space-y-2">
            <ListFilter className="w-8 h-8 text-slate-600 mx-auto" />
            <div className="text-sm font-semibold text-slate-400">لا توجد عمليات تطابق البحث المحدد</div>
            <p className="text-xs text-slate-500">جرب تغيير شروط البحث أو الفلتر أعلاه</p>
          </div>
        ) : (
          filteredTransactions.map(tx => (
            <TransactionItem key={tx.id} transaction={tx} />
          ))
        )}
      </div>

    </div>
  );
};

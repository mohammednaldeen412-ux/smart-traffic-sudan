import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { 
  ArrowLeftRight, 
  CreditCard, 
  PlusCircle, 
  ChevronLeft, 
  Sparkles, 
  ExternalLink,
  Code2,
  Check
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useWallet } from '../context/WalletContext';
import { BankCard } from '../components/BankCard';
import { TransactionItem } from '../components/TransactionItem';

export const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { transactions, beneficiaries, isBalanceHidden, toggleBalanceHidden, deposit } = useWallet();
  
  const [showDepositModal, setShowDepositModal] = useState(false);
  const [depositAmount, setDepositAmount] = useState('10000');
  const [depositSuccess, setDepositSuccess] = useState(false);

  if (!user) return null;

  const recentTransactions = transactions.slice(0, 5);

  const handleQuickDeposit = async () => {
    const amt = parseFloat(depositAmount);
    if (!isNaN(amt) && amt > 0) {
      const res = await deposit(amt);
      if (res.success) {
        setDepositSuccess(true);
        setTimeout(() => {
          setDepositSuccess(false);
          setShowDepositModal(false);
        }, 1200);
      }
    }
  };

  return (
    <div className="space-y-6 pb-20 sm:pb-8 animate-fade-in">
      
      {/* Top Greeting */}
      <div className="flex items-center justify-between">
        <div>
          <span className="text-xs text-slate-400 block font-medium">مرحباً بك مجدداً 👋</span>
          <h1 className="text-xl sm:text-2xl font-extrabold text-white mt-0.5">{user.name}</h1>
        </div>
        
        <div className="text-left">
          <span className="text-[11px] text-emerald-400 bg-emerald-950/60 border border-emerald-800/40 px-2.5 py-1 rounded-xl font-medium inline-block">
            {user.role === 'merchant' ? 'حساب تاجر معتمد' : 'حساب شخصي نشط'}
          </span>
        </div>
      </div>

      {/* Modern Digital Bank Card */}
      <BankCard
        user={user}
        isBalanceHidden={isBalanceHidden}
        onToggleBalance={toggleBalanceHidden}
      />

      {/* Quick Action Buttons Grid */}
      <div className="grid grid-cols-4 gap-3">
        
        {/* Transfer Button */}
        <Link
          to="/transfer"
          className="flex flex-col items-center justify-center p-3 rounded-2xl bg-slate-900/80 hover:bg-slate-800 border border-slate-800 hover:border-emerald-500/40 transition-all text-center group"
        >
          <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <ArrowLeftRight className="w-6 h-6" />
          </div>
          <span className="text-xs font-bold text-slate-200 group-hover:text-emerald-300">تحويل</span>
        </Link>

        {/* Payment Gateway Button */}
        <Link
          to="/pay"
          className="flex flex-col items-center justify-center p-3 rounded-2xl bg-slate-900/80 hover:bg-slate-800 border border-slate-800 hover:border-teal-500/40 transition-all text-center group"
        >
          <div className="w-12 h-12 rounded-2xl bg-teal-500/10 border border-teal-500/20 text-teal-400 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <CreditCard className="w-6 h-6" />
          </div>
          <span className="text-xs font-bold text-slate-200 group-hover:text-teal-300">بوابة الدفع</span>
        </Link>

        {/* Deposit / Top-up Button */}
        <button
          onClick={() => setShowDepositModal(true)}
          className="flex flex-col items-center justify-center p-3 rounded-2xl bg-slate-900/80 hover:bg-slate-800 border border-slate-800 hover:border-blue-500/40 transition-all text-center group"
        >
          <div className="w-12 h-12 rounded-2xl bg-blue-500/10 border border-blue-500/20 text-blue-400 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <PlusCircle className="w-6 h-6" />
          </div>
          <span className="text-xs font-bold text-slate-200 group-hover:text-blue-300">شحن رصيد</span>
        </button>

        {/* Dev Simulator / QR */}
        <Link
          to="/developer"
          className="flex flex-col items-center justify-center p-3 rounded-2xl bg-slate-900/80 hover:bg-slate-800 border border-slate-800 hover:border-amber-500/40 transition-all text-center group"
        >
          <div className="w-12 h-12 rounded-2xl bg-amber-500/10 border border-amber-500/20 text-amber-400 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <Code2 className="w-6 h-6" />
          </div>
          <span className="text-xs font-bold text-slate-200 group-hover:text-amber-300">مختبر الربط</span>
        </Link>

      </div>

      {/* Integration Banner for external app */}
      <div className="p-4 rounded-3xl bg-gradient-to-r from-emerald-950/60 via-slate-900 to-teal-950/60 border border-emerald-500/30 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
            <Sparkles className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-xs sm:text-sm font-bold text-white">هل تود ربط متجرك أو تطبيقك ببوابة بنكك؟</h3>
            <p className="text-[11px] text-slate-400 mt-0.5">استخدم رابط الدفع المباشر أو الـ API التجريبي بكل سهولة</p>
          </div>
        </div>
        <Link
          to="/developer"
          className="shrink-0 flex items-center gap-1 text-xs font-bold text-emerald-400 hover:text-emerald-300 bg-emerald-500/10 hover:bg-emerald-500/20 px-3 py-2 rounded-xl border border-emerald-500/20 transition-all"
        >
          <span>شاهد التوثيق</span>
          <ExternalLink className="w-3.5 h-3.5" />
        </Link>
      </div>

      {/* Quick Beneficiaries (تحويل سريع) */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-sm font-bold text-slate-200">جهات الاتصال للتحويل السريع</h2>
          <span className="text-xs text-slate-500">اختر جهة للتحويل المباشر</span>
        </div>

        <div className="flex items-center gap-3 overflow-x-auto pb-2 scrollbar-none">
          {beneficiaries.map(ben => (
            <button
              key={ben.id}
              onClick={() => navigate(`/transfer?to=${ben.accountNumber}&name=${encodeURIComponent(ben.name)}`)}
              className="flex flex-col items-center shrink-0 p-2.5 rounded-2xl bg-slate-900/60 hover:bg-slate-800 border border-slate-800 hover:border-emerald-500/30 transition-all w-24 text-center group"
            >
              <div className={`w-12 h-12 rounded-full ${ben.avatarColor} text-white font-bold text-sm flex items-center justify-center mb-1.5 shadow-md group-hover:scale-105 transition-transform`}>
                {ben.name.slice(0, 1)}
              </div>
              <span className="text-xs font-semibold text-slate-200 truncate w-full group-hover:text-emerald-300">
                {ben.name.split(' ')[0]}
              </span>
              <span className="text-[9px] text-slate-500 font-mono truncate w-full">
                {ben.accountNumber.slice(-4)}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Recent Transactions */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-sm font-bold text-slate-200">آخر العمليات المصرفية</h2>
          <Link
            to="/history"
            className="text-xs font-semibold text-emerald-400 hover:text-emerald-300 flex items-center gap-1"
          >
            <span>عرض الكل ({transactions.length})</span>
            <ChevronLeft className="w-4 h-4" />
          </Link>
        </div>

        {recentTransactions.length === 0 ? (
          <div className="text-center py-8 rounded-2xl bg-slate-900/40 border border-slate-800 text-slate-500 text-xs">
            لا توجد أي معاملات سابقة حتى الآن
          </div>
        ) : (
          <div className="space-y-2.5">
            {recentTransactions.map(tx => (
              <TransactionItem key={tx.id} transaction={tx} />
            ))}
          </div>
        )}
      </div>

      {/* Mock Deposit / Top-up Modal */}
      {showDepositModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md animate-fade-in">
          <div className="w-full max-w-sm rounded-3xl bg-slate-900 border border-slate-700 p-6 text-center animate-slide-up">
            <div className="w-12 h-12 rounded-2xl bg-blue-500/10 text-blue-400 flex items-center justify-center mx-auto mb-3">
              <PlusCircle className="w-6 h-6" />
            </div>

            <h3 className="text-lg font-bold text-white mb-1">شحن رصيد تجريبي</h3>
            <p className="text-xs text-slate-400 mb-4">أضف أموالاً وهمية إلى حسابك لتجربة عمليات الشراء والتحويل</p>

            <div className="mb-4">
              <label className="block text-xs text-slate-400 mb-1.5 text-right">المبلغ (SDG)</label>
              <input
                type="number"
                value={depositAmount}
                onChange={e => setDepositAmount(e.target.value)}
                className="w-full px-4 py-3 rounded-xl glass-input text-white text-lg font-bold text-center"
              />
            </div>

            <div className="grid grid-cols-3 gap-2 mb-6">
              {[5000, 10000, 50000].map(amt => (
                <button
                  key={amt}
                  type="button"
                  onClick={() => setDepositAmount(amt.toString())}
                  className="py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-xs font-semibold text-slate-300 border border-slate-700"
                >
                  +{amt.toLocaleString('ar-SD')}
                </button>
              ))}
            </div>

            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setShowDepositModal(false)}
                className="flex-1 py-3 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-slate-300 transition-colors"
              >
                إلغاء
              </button>
              <button
                type="button"
                onClick={handleQuickDeposit}
                className="flex-1 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-xs font-extrabold text-slate-950 transition-colors flex items-center justify-center gap-1"
              >
                {depositSuccess ? <Check className="w-4 h-4" /> : null}
                <span>{depositSuccess ? 'تم الشحن بنجاح!' : 'تأكيد الشحن'}</span>
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

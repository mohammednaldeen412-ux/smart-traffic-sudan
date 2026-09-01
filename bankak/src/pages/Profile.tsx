import React, { useState } from 'react';
import { 
  KeyRound, 
  RefreshCw, 
  Copy, 
  Check, 
  Landmark, 
  Smartphone, 
  CheckCircle2,
  AlertCircle
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useWallet } from '../context/WalletContext';
import { formatCurrency } from '../utils/formatters';

export const Profile: React.FC = () => {
  const { user, updatePin, resetAll } = useAuth();
  const { transactions } = useWallet();

  const [newPin, setNewPin] = useState('');
  const [pinSuccess, setPinSuccess] = useState(false);
  const [pinError, setPinError] = useState('');
  const [copiedAccount, setCopiedAccount] = useState(false);
  const [copiedIban, setCopiedIban] = useState(false);
  const [showResetConfirm, setShowResetConfirm] = useState(false);

  if (!user) return null;

  const handleUpdatePin = async (e: React.FormEvent) => {
    e.preventDefault();
    setPinError('');
    setPinSuccess(false);

    if (newPin.length !== 4) {
      setPinError('يجب أن يتكون الـ PIN من 4 أرقام');
      return;
    }

    const res = await updatePin(newPin);
    if (res.success) {
      setPinSuccess(true);
      setNewPin('');
      setTimeout(() => setPinSuccess(false), 3000);
    } else {
      setPinError(res.message || 'فشل تحديث الرمز');
    }
  };

  const copyText = (text: string, type: 'acc' | 'iban') => {
    navigator.clipboard.writeText(text);
    if (type === 'acc') {
      setCopiedAccount(true);
      setTimeout(() => setCopiedAccount(false), 2000);
    } else {
      setCopiedIban(true);
      setTimeout(() => setCopiedIban(false), 2000);
    }
  };

  const handleConfirmReset = () => {
    resetAll();
    setShowResetConfirm(false);
  };

  return (
    <div className="max-w-xl mx-auto space-y-6 pb-20 sm:pb-8 animate-fade-in">
      
      {/* Profile Header */}
      <div className="glass-panel rounded-3xl p-6 text-center relative border border-slate-800">
        <div className="w-20 h-20 rounded-full overflow-hidden bg-emerald-700 mx-auto mb-3 ring-4 ring-emerald-500/20 shadow-xl flex items-center justify-center text-2xl font-bold text-white">
          {user.avatar ? (
            <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
          ) : (
            user.name.slice(0, 1)
          )}
        </div>

        <h1 className="text-xl font-bold text-white">{user.name}</h1>
        <span className="text-xs text-emerald-400 bg-emerald-950/60 border border-emerald-800/40 px-3 py-0.5 rounded-full inline-block mt-1 font-semibold">
          {user.role === 'merchant' ? 'حساب تاجر' : 'حساب شخصي تجريبي'}
        </span>

        {/* Quick Stats Grid */}
        <div className="grid grid-cols-2 gap-3 mt-6 pt-4 border-t border-slate-800 text-xs">
          <div className="p-3 rounded-2xl bg-slate-950/60 border border-slate-800/80">
            <span className="text-slate-400 block mb-0.5">الرصيد الحالي</span>
            <span className="text-sm font-bold text-emerald-400 font-mono">
              {formatCurrency(user.balance, user.currency)}
            </span>
          </div>
          <div className="p-3 rounded-2xl bg-slate-950/60 border border-slate-800/80">
            <span className="text-slate-400 block mb-0.5">إجمالي العمليات</span>
            <span className="text-sm font-bold text-slate-200 font-mono">
              {transactions.length} عملية
            </span>
          </div>
        </div>
      </div>

      {/* Account & Banking Details */}
      <div className="glass-panel rounded-3xl p-6 border border-slate-800 space-y-4">
        <h2 className="text-sm font-bold text-slate-200 flex items-center gap-2">
          <Landmark className="w-4 h-4 text-emerald-400" />
          بيانات الحساب المصرفي
        </h2>

        <div className="space-y-3 text-xs">
          <div className="flex items-center justify-between p-3 rounded-2xl bg-slate-950/50 border border-slate-800">
            <div>
              <span className="text-slate-400 block mb-0.5">رقم الحساب</span>
              <span className="font-mono font-bold text-slate-200 text-sm">{user.accountNumber}</span>
            </div>
            <button
              onClick={() => copyText(user.accountNumber, 'acc')}
              className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
            >
              {copiedAccount ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
            </button>
          </div>

          <div className="flex items-center justify-between p-3 rounded-2xl bg-slate-950/50 border border-slate-800">
            <div>
              <span className="text-slate-400 block mb-0.5">الآيبان الدولي (IBAN)</span>
              <span className="font-mono text-slate-300 text-[11px]">{user.iban}</span>
            </div>
            <button
              onClick={() => copyText(user.iban, 'iban')}
              className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
            >
              {copiedIban ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
            </button>
          </div>

          <div className="flex items-center justify-between p-3 rounded-2xl bg-slate-950/50 border border-slate-800">
            <div>
              <span className="text-slate-400 block mb-0.5">رقم الهاتف المسجل</span>
              <span className="font-mono text-slate-200">{user.phone}</span>
            </div>
            <Smartphone className="w-4 h-4 text-slate-500" />
          </div>
        </div>
      </div>

      {/* Change Security PIN */}
      <div className="glass-panel rounded-3xl p-6 border border-slate-800 space-y-4">
        <h2 className="text-sm font-bold text-slate-200 flex items-center gap-2">
          <KeyRound className="w-4 h-4 text-amber-400" />
          تغيير رمز الـ PIN السري
        </h2>

        <form onSubmit={handleUpdatePin} className="space-y-3">
          <div>
            <label className="block text-xs text-slate-400 mb-1">
              أدخل رمز PIN الجديد (4 أرقام)
            </label>
            <input
              type="password"
              maxLength={4}
              value={newPin}
              onChange={e => setNewPin(e.target.value)}
              placeholder="مثال: 5678"
              className="w-full px-4 py-2.5 rounded-xl glass-input text-white text-sm tracking-widest text-center focus:outline-none"
              required
            />
          </div>

          {pinSuccess && (
            <div className="p-2.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs flex items-center gap-1.5 justify-center">
              <CheckCircle2 className="w-4 h-4" />
              <span>تم تحديث رمز الـ PIN بنجاح!</span>
            </div>
          )}

          {pinError && (
            <div className="p-2.5 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center gap-1.5 justify-center">
              <AlertCircle className="w-4 h-4" />
              <span>{pinError}</span>
            </div>
          )}

          <button
            type="submit"
            className="w-full py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-slate-200 border border-slate-700 transition-colors"
          >
            حفظ الرمز الجديد
          </button>
        </form>
      </div>

      {/* Reset System Data */}
      <div className="glass-panel rounded-3xl p-6 border border-rose-950/60 bg-rose-950/10 space-y-3">
        <div className="flex items-center gap-2 text-rose-400 text-xs font-bold">
          <RefreshCw className="w-4 h-4" />
          <span>إعادة ضبط البيانات التجريبية</span>
        </div>
        <p className="text-xs text-slate-400 leading-relaxed">
          إعادة تعيين كافة الأرصدة وسجل العمليات والحسابات إلى الحالة الأصلية الافتراضية.
        </p>

        {showResetConfirm ? (
          <div className="p-3 rounded-2xl bg-rose-500/10 border border-rose-500/30 space-y-2">
            <span className="text-xs text-rose-300 block font-semibold">هل أنت متأكد من رغبتك في إعادة التعيين؟</span>
            <div className="flex gap-2">
              <button
                onClick={() => setShowResetConfirm(false)}
                className="flex-1 py-1.5 rounded-xl bg-slate-800 text-xs font-bold text-slate-300"
              >
                إلغاء
              </button>
              <button
                onClick={handleConfirmReset}
                className="flex-1 py-1.5 rounded-xl bg-rose-600 hover:bg-rose-500 text-xs font-bold text-white"
              >
                نعم، إعادة ضبط الآن
              </button>
            </div>
          </div>
        ) : (
          <button
            type="button"
            onClick={() => setShowResetConfirm(true)}
            className="py-2.5 px-4 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 text-xs font-bold border border-rose-500/30 transition-colors"
          >
            إعادة تعيين البيانات الافتراضية
          </button>
        )}
      </div>

    </div>
  );
};

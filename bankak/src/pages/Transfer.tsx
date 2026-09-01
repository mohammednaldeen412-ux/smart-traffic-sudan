import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { 
  ArrowLeftRight, 
  User, 
  Hash, 
  DollarSign, 
  FileText, 
  AlertCircle, 
  ArrowRight
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useWallet } from '../context/WalletContext';
import { PinModal } from '../components/PinModal';
import { formatCurrency } from '../utils/formatters';

export const Transfer: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const { user } = useAuth();
  const { beneficiaries, sendTransfer } = useWallet();

  const [recipientAccount, setRecipientAccount] = useState('');
  const [recipientName, setRecipientName] = useState('');
  const [amount, setAmount] = useState('');
  const [note, setNote] = useState('');
  const [error, setError] = useState('');
  const [showPinModal, setShowPinModal] = useState(false);

  // Pre-fill if navigated from quick contact
  useEffect(() => {
    const to = searchParams.get('to');
    const name = searchParams.get('name');
    if (to) setRecipientAccount(to);
    if (name) setRecipientName(name);
  }, [searchParams]);

  if (!user) return null;

  const numericAmount = parseFloat(amount) || 0;
  const transferFee = 100; // 100 SDG mock transfer fee
  const totalAmount = numericAmount > 0 ? numericAmount + transferFee : 0;

  const handleSelectBeneficiary = (ben: typeof beneficiaries[0]) => {
    setRecipientAccount(ben.accountNumber);
    setRecipientName(ben.name);
    setError('');
  };

  const handleInitiateTransfer = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!recipientAccount.trim()) {
      setError('يرجى إدخال رقم حساب أو هاتف المستلم');
      return;
    }

    if (numericAmount <= 0) {
      setError('يرجى إدخال مبلغ تحويل صحيح');
      return;
    }

    if (totalAmount > user.balance) {
      setError(`رصيدك غير كافٍ. المبلغ الإجمالي مع الرسوم (${formatCurrency(totalAmount, user.currency)}) يتجاوز رصيدك الحالي (${formatCurrency(user.balance, user.currency)})`);
      return;
    }

    setShowPinModal(true);
  };

  const handleConfirmPin = async (pin: string) => {
    const res = await sendTransfer({
      recipientAccount,
      recipientName: recipientName || 'مستلم بنكك',
      amount: numericAmount,
      note,
      pin,
    });

    if (res.success && res.transaction) {
      setShowPinModal(false);
      navigate(`/receipt/${res.transaction.id}`);
      return true;
    } else {
      setError(res.message || 'فشلت العملية، تأكد من الرمز');
      return false;
    }
  };

  return (
    <div className="max-w-xl mx-auto space-y-6 pb-20 sm:pb-8 animate-fade-in">
      
      {/* Header */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
        >
          <ArrowRight className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-xl font-bold text-white flex items-center gap-2">
            <ArrowLeftRight className="w-5 h-5 text-emerald-400" />
            تحويل مالي بين الحسابات
          </h1>
          <p className="text-xs text-slate-400">تحويل فوري إلى أي حساب أو محفظة بنكك</p>
        </div>
      </div>

      {/* Available Balance Box */}
      <div className="p-4 rounded-2xl glass-panel-emerald flex items-center justify-between text-white shadow-lg">
        <div>
          <span className="text-xs text-emerald-200/80 block">الرصيد المتاح للتحويل</span>
          <span className="text-xl font-black">{formatCurrency(user.balance, user.currency)}</span>
        </div>
        <div className="text-left text-xs text-emerald-200">
          <span>رسوم الخدمة: </span>
          <span className="font-bold">100 SDG</span>
        </div>
      </div>

      {/* Saved Beneficiaries Quick Select */}
      <div>
        <label className="block text-xs font-semibold text-slate-300 mb-2">
          جهات الاتصال المحفوظة
        </label>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
          {beneficiaries.map(ben => (
            <button
              key={ben.id}
              type="button"
              onClick={() => handleSelectBeneficiary(ben)}
              className={`p-2.5 rounded-xl border text-right transition-all flex items-center gap-2 ${
                recipientAccount === ben.accountNumber
                  ? 'bg-emerald-950/60 border-emerald-500 text-emerald-300'
                  : 'bg-slate-900/60 border-slate-800 hover:border-slate-700 text-slate-300'
              }`}
            >
              <div className={`w-8 h-8 rounded-full ${ben.avatarColor} text-white font-bold text-xs flex items-center justify-center shrink-0`}>
                {ben.name.slice(0, 1)}
              </div>
              <div className="truncate">
                <div className="text-xs font-bold truncate">{ben.name.split(' ')[0]}</div>
                <div className="text-[10px] text-slate-400 font-mono">{ben.accountNumber.slice(-4)}</div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Transfer Form */}
      <form onSubmit={handleInitiateTransfer} className="glass-panel rounded-3xl p-6 space-y-4 border border-slate-800">
        
        {/* Recipient Account / Phone */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 mb-1.5">
            رقم حساب المستلم أو رقم الهاتف
          </label>
          <div className="relative">
            <input
              type="text"
              value={recipientAccount}
              onChange={e => {
                setRecipientAccount(e.target.value);
                setError('');
              }}
              placeholder="مثال: 2981029384 أو 0912345678"
              className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-sm focus:outline-none"
              required
            />
            <Hash className="w-5 h-5 text-slate-400 absolute top-3.5 right-3.5" />
          </div>
        </div>

        {/* Recipient Name (Optional) */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 mb-1.5">
            اسم المستلم (اختياري)
          </label>
          <div className="relative">
            <input
              type="text"
              value={recipientName}
              onChange={e => setRecipientName(e.target.value)}
              placeholder="مثال: محمد عبد الله"
              className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-sm focus:outline-none"
            />
            <User className="w-5 h-5 text-slate-400 absolute top-3.5 right-3.5" />
          </div>
        </div>

        {/* Amount Input */}
        <div>
          <div className="flex items-center justify-between mb-1.5">
            <label className="text-xs font-semibold text-slate-300">
              المبلغ المطلوب تحويله (SDG)
            </label>
            {user.balance > 100 && (
              <button
                type="button"
                onClick={() => setAmount(Math.max(0, user.balance - transferFee).toString())}
                className="text-[11px] text-emerald-400 hover:text-emerald-300 font-semibold"
              >
                أقصى مبلغ متاح
              </button>
            )}
          </div>

          <div className="relative">
            <input
              type="number"
              min="1"
              max={user.balance}
              value={amount}
              onChange={e => {
                setAmount(e.target.value);
                setError('');
              }}
              placeholder="0.00"
              className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-lg font-bold focus:outline-none"
              required
            />
            <DollarSign className="w-5 h-5 text-emerald-400 absolute top-3.5 right-3.5" />
          </div>

          {/* Quick Amount Chips */}
          <div className="grid grid-cols-4 gap-2 mt-2">
            {[500, 1000, 5000, 10000].map(chipAmt => (
              <button
                key={chipAmt}
                type="button"
                onClick={() => setAmount(chipAmt.toString())}
                className="py-1.5 rounded-xl bg-slate-800/80 hover:bg-slate-700 text-xs font-semibold text-slate-300 border border-slate-700/60"
              >
                {chipAmt.toLocaleString('ar-SD')}
              </button>
            ))}
          </div>
        </div>

        {/* Purpose / Note */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 mb-1.5">
            الغرض أو الملاحظات (اختياري)
          </label>
          <div className="relative">
            <input
              type="text"
              value={note}
              onChange={e => setNote(e.target.value)}
              placeholder="مثال: سداد إيجار، دفعة شراء، هدية..."
              className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-sm focus:outline-none"
            />
            <FileText className="w-5 h-5 text-slate-400 absolute top-3.5 right-3.5" />
          </div>
        </div>

        {/* Summary Breakdown */}
        {numericAmount > 0 && (
          <div className="p-3.5 rounded-2xl bg-slate-950/60 border border-slate-800 space-y-1.5 text-xs">
            <div className="flex justify-between text-slate-400">
              <span>المبلغ المحول</span>
              <span className="font-mono text-slate-200">{formatCurrency(numericAmount, user.currency)}</span>
            </div>
            <div className="flex justify-between text-slate-400">
              <span>رسوم التحويل</span>
              <span className="font-mono text-slate-200">{formatCurrency(transferFee, user.currency)}</span>
            </div>
            <div className="pt-2 border-t border-slate-800 flex justify-between font-bold text-white text-sm">
              <span>الإجمالي المخصوم</span>
              <span className="font-mono text-emerald-400">{formatCurrency(totalAmount, user.currency)}</span>
            </div>
          </div>
        )}

        {/* Error Alert */}
        {error && (
          <div className="p-3 rounded-2xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center gap-2">
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {/* Action Button */}
        <button
          type="submit"
          className="w-full py-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 font-extrabold text-sm shadow-lg shadow-emerald-500/25 active:scale-[0.99] transition-all flex items-center justify-center gap-2"
        >
          <span>المتابعة والتأكيد بالرمز</span>
          <ArrowRight className="w-4 h-4 rotate-180" />
        </button>

      </form>

      {/* PIN Confirmation Modal */}
      <PinModal
        isOpen={showPinModal}
        onClose={() => setShowPinModal(false)}
        onSuccess={handleConfirmPin}
        title="تأكيد تحويل المبلغ"
        subtitle={`أدخل رمز PIN لتأكيد تحويل ${formatCurrency(numericAmount, user.currency)} إلى ${recipientName || recipientAccount}`}
        amount={totalAmount}
        currency={user.currency}
      />

    </div>
  );
};

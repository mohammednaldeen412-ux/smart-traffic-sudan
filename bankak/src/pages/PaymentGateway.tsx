import React, { useState, useEffect } from 'react';
import { useSearchParams, useNavigate, Link } from 'react-router-dom';
import { 
  ShieldCheck, 
  Store, 
  CreditCard, 
  AlertCircle, 
  Lock, 
  ExternalLink, 
  Info,
  CheckCircle2,
  ReceiptText
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { useAuth } from '../context/AuthContext';
import { useWallet } from '../context/WalletContext';
import type { PaymentRequest } from '../types';
import type { PaymentExecutionResult } from '../services/gatewayService';
import { gatewayService } from '../services/gatewayService';
import { PinModal } from '../components/PinModal';
import { formatCurrency } from '../utils/formatters';

export const PaymentGateway: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { deposit } = useWallet();

  const [paymentReq, setPaymentReq] = useState<PaymentRequest>({
    merchant: 'متجر التطبيق الرئيسي التجريبي',
    amount: 3500.00,
    currency: 'SDG',
    order_id: 'ORD-' + Math.floor(100000 + Math.random() * 900000),
    description: 'سداد قيمة مشتريات / اشتراك رقمي من التطبيق الرئيسي',
    callback_url: 'http://localhost:3000/checkout/success',
  });

  const [showPinModal, setShowPinModal] = useState(false);
  const [error, setError] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [resultData, setResultData] = useState<PaymentExecutionResult | null>(null);
  const [redirectCountdown, setRedirectCountdown] = useState<number | null>(null);

  // Read URL parameters if provided
  useEffect(() => {
    const parsed = gatewayService.parseFromSearchParams(searchParams);
    if (parsed) {
      setPaymentReq(parsed);
    }
  }, [searchParams]);

  // Handle countdown redirection if callback_url exists
  useEffect(() => {
    if (isSuccess && resultData?.redirectUrl && redirectCountdown !== null && redirectCountdown > 0) {
      const timer = setTimeout(() => {
        setRedirectCountdown(prev => (prev !== null ? prev - 1 : null));
      }, 1000);
      return () => clearTimeout(timer);
    } else if (isSuccess && resultData?.redirectUrl && redirectCountdown === 0) {
      window.location.href = resultData.redirectUrl;
    }
  }, [isSuccess, resultData, redirectCountdown]);

  if (!user) return null;

  const isInsufficient = user.balance < paymentReq.amount;

  const handleStartPayment = () => {
    setError('');
    if (paymentReq.amount <= 0) {
      setError('مبلغ العملية غير صحيح');
      return;
    }
    if (isInsufficient) {
      setError('رصيدك الحالي غير كافٍ. يرجى شحن الرصيد التجريبي للمتابعة.');
      return;
    }
    setShowPinModal(true);
  };

  const handleConfirmPin = async (pin: string) => {
    const res = await gatewayService.processPayment({
      paymentRequest: paymentReq,
      pin,
    });

    if (res.success && res.data) {
      setShowPinModal(false);
      setResultData(res.data);
      setIsSuccess(true);

      // Trigger festive confetti
      confetti({
        particleCount: 80,
        spread: 70,
        origin: { y: 0.6 },
        colors: ['#10b981', '#059669', '#34d399', '#fbbf24'],
      });

      if (res.data.redirectUrl) {
        setRedirectCountdown(4); // 4 seconds auto-redirect
      }
      return true;
    } else {
      setError(res.message || 'فشلت عملية الدفع');
      return false;
    }
  };

  const handleTopupAndContinue = async () => {
    await deposit(paymentReq.amount + 5000);
    setError('');
  };

  return (
    <div className="max-w-xl mx-auto space-y-6 pb-20 sm:pb-8 animate-fade-in">
      
      {/* Top Banner Indicator */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 text-xs text-slate-400">
          <ShieldCheck className="w-4 h-4 text-emerald-400" />
          <span>بوابة دفع إلكترونية آمنة (Mock Gateway)</span>
        </div>
        <Link
          to="/developer"
          className="text-xs text-emerald-400 hover:text-emerald-300 font-semibold flex items-center gap-1"
        >
          <span>تخصيص الطلب</span>
          <ExternalLink className="w-3 h-3" />
        </Link>
      </div>

      {/* If Payment Succeeded */}
      {isSuccess && resultData ? (
        <div className="glass-panel rounded-3xl p-6 sm:p-8 text-center space-y-6 border border-emerald-500/30 animate-slide-up">
          
          {/* Animated Success Badge */}
          <div className="w-20 h-20 rounded-full bg-emerald-500/20 border-2 border-emerald-400 flex items-center justify-center text-emerald-400 mx-auto shadow-lg shadow-emerald-500/30">
            <CheckCircle2 className="w-10 h-10 animate-bounce" />
          </div>

          <div>
            <span className="text-xs font-bold text-emerald-400 uppercase tracking-widest block mb-1">
              عملية دفع ناجحة
            </span>
            <h2 className="text-2xl font-black text-white">
              {formatCurrency(paymentReq.amount, paymentReq.currency)}
            </h2>
            <p className="text-xs text-slate-400 mt-1">
              تم خصم المبلغ وتحويله إلى <span className="text-slate-200 font-bold">{paymentReq.merchant}</span>
            </p>
          </div>

          {/* Receipt Info Card */}
          <div className="p-4 rounded-2xl bg-slate-950/70 border border-slate-800 space-y-2 text-right text-xs">
            <div className="flex justify-between text-slate-400">
              <span>رقم المعاملة (TXN ID)</span>
              <span className="font-mono text-slate-200 font-bold">{resultData.transaction.id}</span>
            </div>
            <div className="flex justify-between text-slate-400">
              <span>رقم الطلب (Order ID)</span>
              <span className="font-mono text-slate-200">{paymentReq.order_id}</span>
            </div>
            <div className="flex justify-between text-slate-400">
              <span>المرجع البنكي</span>
              <span className="font-mono text-slate-200">{resultData.transaction.referenceNumber}</span>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="space-y-3">
            {resultData.redirectUrl ? (
              <a
                href={resultData.redirectUrl}
                className="w-full py-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 text-slate-950 font-extrabold text-sm shadow-lg shadow-emerald-500/25 transition-all flex items-center justify-center gap-2"
              >
                <span>العودة إلى {paymentReq.merchant}</span>
                {redirectCountdown !== null && (
                  <span className="text-xs px-2 py-0.5 rounded-full bg-slate-950/20">
                    (تلقائياً خلال {redirectCountdown}ث)
                  </span>
                )}
                <ExternalLink className="w-4 h-4" />
              </a>
            ) : null}

            <div className="flex gap-2">
              <button
                onClick={() => navigate(`/receipt/${resultData.transaction.id}`)}
                className="flex-1 py-3 rounded-2xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-slate-200 border border-slate-700 transition-colors flex items-center justify-center gap-1.5"
              >
                <ReceiptText className="w-4 h-4 text-emerald-400" />
                <span>عرض الإيصال الكامل</span>
              </button>

              <button
                onClick={() => navigate('/')}
                className="flex-1 py-3 rounded-2xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-slate-200 border border-slate-700 transition-colors"
              >
                الصفحة الرئيسية
              </button>
            </div>
          </div>

        </div>
      ) : (
        /* Payment Checkout Form */
        <div className="glass-panel rounded-3xl p-6 sm:p-8 space-y-6 border border-slate-800 shadow-2xl">
          
          {/* Merchant Header */}
          <div className="p-4 rounded-2xl bg-gradient-to-r from-slate-900 to-slate-850 border border-slate-800 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                <Store className="w-6 h-6" />
              </div>
              <div>
                <span className="text-[10px] text-emerald-400 font-bold uppercase tracking-wider block">طلب دفع تجاري</span>
                <h2 className="text-base font-bold text-white">{paymentReq.merchant}</h2>
                <div className="text-xs text-slate-400 font-mono mt-0.5">طلب: #{paymentReq.order_id}</div>
              </div>
            </div>
          </div>

          {/* Amount Showcase */}
          <div className="text-center py-4 px-6 rounded-2xl bg-slate-950/60 border border-slate-800/80">
            <span className="text-xs text-slate-400 block mb-1">المبلغ المطلوب سداده</span>
            <div className="text-3xl font-black text-white tracking-tight">
              {formatCurrency(paymentReq.amount, paymentReq.currency)}
            </div>
            {paymentReq.description && (
              <p className="text-xs text-slate-400 mt-2 px-4 leading-relaxed">
                {paymentReq.description}
              </p>
            )}
          </div>

          {/* User Account & Balance Preview */}
          <div className="p-4 rounded-2xl bg-slate-900/90 border border-slate-800 space-y-3">
            <div className="flex items-center justify-between text-xs">
              <span className="text-slate-400 flex items-center gap-1.5">
                <CreditCard className="w-4 h-4 text-slate-400" />
                حساب الدفع المختار
              </span>
              <span className="text-emerald-400 font-bold">حساب بنكك الجاري</span>
            </div>

            <div className="flex items-center justify-between pt-2 border-t border-slate-800">
              <div>
                <span className="text-[11px] text-slate-400 block">صاحب الحساب</span>
                <span className="text-xs font-bold text-slate-200">{user.name}</span>
              </div>
              <div className="text-left">
                <span className="text-[11px] text-slate-400 block">رصيدك الحالي</span>
                <span className={`text-xs font-bold font-mono ${isInsufficient ? 'text-rose-400' : 'text-emerald-400'}`}>
                  {formatCurrency(user.balance, user.currency)}
                </span>
              </div>
            </div>

            {/* Insufficient balance alert + Quick topup */}
            {isInsufficient && (
              <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-300 text-xs space-y-2">
                <div className="flex items-center gap-1.5">
                  <AlertCircle className="w-4 h-4 shrink-0 text-rose-400" />
                  <span>الرصيد غير كافٍ لسداد هذا الطلب</span>
                </div>
                <button
                  type="button"
                  onClick={handleTopupAndContinue}
                  className="w-full py-1.5 rounded-lg bg-rose-500/20 hover:bg-rose-500/30 text-rose-200 font-bold transition-colors text-center text-xs"
                >
                  + شحن رصيد تجريبي فوري ({formatCurrency(paymentReq.amount + 5000, user.currency)})
                </button>
              </div>
            )}
          </div>

          {/* Security & Callback note */}
          {paymentReq.callback_url && (
            <div className="flex items-start gap-2 p-3 rounded-xl bg-slate-900/50 border border-slate-800/80 text-[11px] text-slate-400">
              <Info className="w-4 h-4 text-teal-400 shrink-0 mt-0.5" />
              <span>
                سيتم إرجاع نتيجة العملية تلقائياً إلى رابط التطبيق الرئيسي:
                <br />
                <code className="text-[10px] text-slate-300 font-mono break-all">{paymentReq.callback_url}</code>
              </span>
            </div>
          )}

          {/* Error Alert */}
          {error && (
            <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center gap-2">
              <AlertCircle className="w-4 h-4 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          {/* Pay Button */}
          <button
            type="button"
            onClick={handleStartPayment}
            className="w-full py-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 font-extrabold text-sm shadow-lg shadow-emerald-500/25 active:scale-[0.99] transition-all flex items-center justify-center gap-2"
          >
            <Lock className="w-4 h-4" />
            <span>تأكيد الدفع عبر بنكك ({formatCurrency(paymentReq.amount, paymentReq.currency)})</span>
          </button>

        </div>
      )}

      {/* PIN Confirmation Modal */}
      <PinModal
        isOpen={showPinModal}
        onClose={() => setShowPinModal(false)}
        onSuccess={handleConfirmPin}
        title="تأكيد عملية الدفع"
        subtitle={`أدخل رمز PIN للموافقة على سداد ${formatCurrency(paymentReq.amount, paymentReq.currency)} لصالح ${paymentReq.merchant}`}
        amount={paymentReq.amount}
        currency={paymentReq.currency}
      />

    </div>
  );
};

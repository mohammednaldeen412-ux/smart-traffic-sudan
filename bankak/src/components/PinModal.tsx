import React, { useState, useEffect } from 'react';
import { Lock, Delete, X, AlertCircle, Loader2 } from 'lucide-react';

interface PinModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (pin: string) => Promise<boolean | void> | boolean | void;
  title?: string;
  subtitle?: string;
  amount?: number;
  currency?: string;
}

export const PinModal: React.FC<PinModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
  title = 'تأكيد العملية برمز PIN',
  subtitle = 'أدخل رمز الـ PIN المكون من 4 أرقام للمتابعة (الافتراضي: 1234)',
  amount,
  currency = 'SDG',
}) => {
  const [pin, setPin] = useState<string>('');
  const [error, setError] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  useEffect(() => {
    if (isOpen) {
      setPin('');
      setError('');
      setIsSubmitting(false);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleKeyPress = (digit: string) => {
    if (pin.length < 4 && !isSubmitting) {
      const nextPin = pin + digit;
      setPin(nextPin);
      setError('');
      if (nextPin.length === 4) {
        submitPin(nextPin);
      }
    }
  };

  const handleDelete = () => {
    if (pin.length > 0 && !isSubmitting) {
      setPin(pin.slice(0, -1));
      setError('');
    }
  };

  const submitPin = async (completedPin: string) => {
    setIsSubmitting(true);
    try {
      const result = await onSuccess(completedPin);
      if (result === false) {
        setError('رمز الـ PIN غير صحيح، يرجى المحاولة مجدداً');
        setPin('');
        setIsSubmitting(false);
      }
    } catch {
      setError('حدث خطأ أثناء التحقق من الرمز');
      setPin('');
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-sm overflow-hidden rounded-3xl bg-slate-900 border border-slate-700/80 shadow-2xl p-6 text-center animate-slide-up">
        {/* Close Button */}
        <button
          onClick={onClose}
          disabled={isSubmitting}
          className="absolute top-4 left-4 p-2 rounded-full text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Lock Icon */}
        <div className="mx-auto w-14 h-14 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 mb-4 shadow-inner">
          <Lock className="w-7 h-7" />
        </div>

        <h3 className="text-xl font-bold text-white mb-1">{title}</h3>
        <p className="text-xs text-slate-400 mb-4 px-2">{subtitle}</p>

        {amount !== undefined && amount > 0 && (
          <div className="mb-5 py-2.5 px-4 rounded-xl bg-slate-800/80 border border-slate-700/50 inline-block">
            <span className="text-xs text-slate-400 block mb-0.5">المبلغ المطلوب تأكيده</span>
            <span className="text-lg font-extrabold text-emerald-400">
              {amount.toLocaleString('ar-SD')} {currency}
            </span>
          </div>
        )}

        {/* PIN Indicators (4 Dots) */}
        <div className="flex justify-center items-center gap-4 mb-6">
          {[0, 1, 2, 3].map(index => {
            const isFilled = pin.length > index;
            return (
              <div
                key={index}
                className={`w-4 h-4 rounded-full transition-all duration-200 ${
                  isFilled
                    ? 'bg-emerald-400 scale-110 shadow-[0_0_12px_rgba(52,211,153,0.8)]'
                    : 'bg-slate-700 border border-slate-600'
                }`}
              />
            );
          })}
        </div>

        {/* Error Alert */}
        {error && (
          <div className="mb-4 flex items-center justify-center gap-1.5 text-rose-400 text-xs bg-rose-500/10 py-2 px-3 rounded-lg border border-rose-500/20">
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {/* Keypad */}
        <div className="grid grid-cols-3 gap-3 max-w-[260px] mx-auto mb-2">
          {['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(num => (
            <button
              key={num}
              type="button"
              onClick={() => handleKeyPress(num)}
              disabled={isSubmitting || pin.length >= 4}
              className="h-14 rounded-2xl bg-slate-800/90 hover:bg-slate-700 active:scale-95 text-xl font-bold text-slate-100 transition-all border border-slate-700/60 shadow-sm flex items-center justify-center disabled:opacity-50"
            >
              {num}
            </button>
          ))}

          {/* Quick Demo PIN Helper */}
          <button
            type="button"
            onClick={() => {
              setPin('1234');
              submitPin('1234');
            }}
            disabled={isSubmitting}
            className="h-14 rounded-2xl bg-emerald-950/40 hover:bg-emerald-900/50 active:scale-95 text-xs font-medium text-emerald-400 border border-emerald-800/40 flex flex-col items-center justify-center transition-all disabled:opacity-50"
          >
            <span>رمز تجريبي</span>
            <span className="font-mono text-[10px] text-emerald-300">1234</span>
          </button>

          <button
            type="button"
            onClick={() => handleKeyPress('0')}
            disabled={isSubmitting || pin.length >= 4}
            className="h-14 rounded-2xl bg-slate-800/90 hover:bg-slate-700 active:scale-95 text-xl font-bold text-slate-100 transition-all border border-slate-700/60 shadow-sm flex items-center justify-center disabled:opacity-50"
          >
            0
          </button>

          <button
            type="button"
            onClick={handleDelete}
            disabled={isSubmitting || pin.length === 0}
            className="h-14 rounded-2xl bg-slate-800/60 hover:bg-slate-700/80 active:scale-95 text-slate-300 transition-all border border-slate-700/60 flex items-center justify-center disabled:opacity-40"
          >
            <Delete className="w-5 h-5" />
          </button>
        </div>

        {isSubmitting && (
          <div className="mt-3 flex items-center justify-center gap-2 text-emerald-400 text-xs font-medium animate-pulse">
            <Loader2 className="w-4 h-4 animate-spin" />
            <span>جاري التحقق من الرمز وتأكيد العملية...</span>
          </div>
        )}
      </div>
    </div>
  );
};

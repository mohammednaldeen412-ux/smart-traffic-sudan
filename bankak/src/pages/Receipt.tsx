import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { 
  CheckCircle2, 
  XCircle, 
  Copy, 
  Check, 
  Printer, 
  Share2, 
  ArrowRight, 
  ExternalLink
} from 'lucide-react';
import type { Transaction } from '../types';
import { walletService } from '../services/walletService';
import { formatCurrency, formatDate } from '../utils/formatters';

export const Receipt: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [transaction, setTransaction] = useState<Transaction | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [copiedId, setCopiedId] = useState(false);
  const [copiedRef, setCopiedRef] = useState(false);

  useEffect(() => {
    if (id) {
      walletService.getTransactionById(id).then(res => {
        if (res.success && res.data) {
          setTransaction(res.data);
        }
        setIsLoading(false);
      });
    }
  }, [id]);

  if (isLoading) {
    return (
      <div className="text-center py-20 text-slate-400 text-sm">
        جاري تحميل بيانات الإيصال...
      </div>
    );
  }

  if (!transaction) {
    return (
      <div className="max-w-md mx-auto text-center py-16 space-y-4">
        <div className="w-16 h-16 rounded-full bg-rose-500/10 text-rose-400 flex items-center justify-center mx-auto">
          <XCircle className="w-8 h-8" />
        </div>
        <h2 className="text-lg font-bold text-white">لم يتم العثور على المعاملة</h2>
        <p className="text-xs text-slate-400">تأكد من صحة رقم المعاملة أو عد للصفحة الرئيسية</p>
        <button
          onClick={() => navigate('/')}
          className="px-6 py-2.5 rounded-xl bg-slate-800 text-xs font-bold text-white hover:bg-slate-700"
        >
          العودة للرئيسية
        </button>
      </div>
    );
  }

  const copyToClipboard = (text: string, isRef: boolean = false) => {
    navigator.clipboard.writeText(text);
    if (isRef) {
      setCopiedRef(true);
      setTimeout(() => setCopiedRef(false), 2000);
    } else {
      setCopiedId(true);
      setTimeout(() => setCopiedId(false), 2000);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const isSuccess = transaction.status === 'success';

  return (
    <div className="max-w-lg mx-auto space-y-6 pb-20 sm:pb-8 animate-fade-in print:p-0 print:m-0">
      
      {/* Header Actions */}
      <div className="flex items-center justify-between print:hidden">
        <button
          onClick={() => navigate('/')}
          className="flex items-center gap-1.5 text-xs font-semibold text-slate-400 hover:text-white"
        >
          <ArrowRight className="w-4 h-4" />
          <span>الصفحة الرئيسية</span>
        </button>

        <div className="flex items-center gap-2">
          <button
            onClick={handlePrint}
            className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
            title="طباعة الإيصال"
          >
            <Printer className="w-4 h-4" />
          </button>
          <button
            onClick={() => copyToClipboard(window.location.href)}
            className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
            title="نسخ رابط الإيصال"
          >
            <Share2 className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* The Printable Receipt Card */}
      <div className="glass-panel rounded-3xl p-6 sm:p-8 border border-slate-800 space-y-6 relative overflow-hidden shadow-2xl print:border-none print:shadow-none print:bg-white print:text-black">
        
        {/* Top Header */}
        <div className="text-center pb-6 border-b border-slate-800">
          
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-emerald-500/20 text-emerald-400 mb-3 border-2 border-emerald-500/40">
            {isSuccess ? <CheckCircle2 className="w-8 h-8" /> : <XCircle className="w-8 h-8 text-rose-400" />}
          </div>

          <div className="text-xs font-bold uppercase tracking-widest text-emerald-400 mb-1">
            {isSuccess ? 'إشعار معاملة ناجحة' : 'معاملة غير مكتملة'}
          </div>

          <div className="text-3xl font-black text-white print:text-black font-mono">
            {formatCurrency(transaction.amount, transaction.currency)}
          </div>

          <p className="text-xs text-slate-400 mt-1">{transaction.title}</p>
        </div>

        {/* Details Grid */}
        <div className="space-y-3.5 text-xs">
          
          <div className="flex items-center justify-between">
            <span className="text-slate-400">رقم المعاملة (TXN ID)</span>
            <button
              onClick={() => copyToClipboard(transaction.id)}
              className="flex items-center gap-1 font-mono font-bold text-slate-200 hover:text-emerald-400 transition-colors"
            >
              <span>{transaction.id}</span>
              {copiedId ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5 text-slate-500" />}
            </button>
          </div>

          <div className="flex items-center justify-between">
            <span className="text-slate-400">المرجع البنكي (Ref)</span>
            <button
              onClick={() => copyToClipboard(transaction.referenceNumber, true)}
              className="flex items-center gap-1 font-mono text-slate-300 hover:text-emerald-400 transition-colors"
            >
              <span>{transaction.referenceNumber}</span>
              {copiedRef ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5 text-slate-500" />}
            </button>
          </div>

          <div className="flex items-center justify-between">
            <span className="text-slate-400">التاريخ والوقت</span>
            <span className="text-slate-200 font-mono">{formatDate(transaction.timestamp)}</span>
          </div>

          {transaction.orderId && (
            <div className="flex items-center justify-between">
              <span className="text-slate-400">رقم الطلب (Order ID)</span>
              <span className="text-slate-200 font-mono font-bold">#{transaction.orderId}</span>
            </div>
          )}

          {transaction.merchantName && (
            <div className="flex items-center justify-between">
              <span className="text-slate-400">المتجر / التاجر</span>
              <span className="text-slate-200 font-bold">{transaction.merchantName}</span>
            </div>
          )}

          {transaction.recipientName && (
            <div className="flex items-center justify-between">
              <span className="text-slate-400">المستلم</span>
              <span className="text-slate-200 font-bold">{transaction.recipientName}</span>
            </div>
          )}

          {transaction.recipientAccount && (
            <div className="flex items-center justify-between">
              <span className="text-slate-400">حساب المستلم</span>
              <span className="text-slate-200 font-mono">{transaction.recipientAccount}</span>
            </div>
          )}

          <div className="flex items-center justify-between">
            <span className="text-slate-400">المرسل</span>
            <span className="text-slate-200 font-bold">{transaction.senderName || 'حساب بنكك'}</span>
          </div>

          <div className="flex items-center justify-between">
            <span className="text-slate-400">رسوم المعاملة</span>
            <span className="text-slate-200 font-mono">
              {transaction.fee > 0 ? formatCurrency(transaction.fee, transaction.currency) : 'مجاناً (0.00 SDG)'}
            </span>
          </div>

          {transaction.description && (
            <div className="pt-2 border-t border-slate-800 text-slate-400 leading-relaxed">
              <span className="block text-[11px] text-slate-500 mb-0.5">ملاحظات:</span>
              <span>{transaction.description}</span>
            </div>
          )}

        </div>

        {/* Bank Seal / Stamp watermark */}
        <div className="pt-4 border-t border-slate-800 text-center">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-[10px] font-bold">
            <span>معتمد إلكترونياً من نظام بنكك التجريبي</span>
          </div>
        </div>

      </div>

      {/* Return to External App or Dashboard */}
      <div className="space-y-3 print:hidden">
        {transaction.callbackUrl && (
          <a
            href={`${transaction.callbackUrl}?status=success&txn_id=${transaction.id}&order_id=${transaction.orderId || ''}`}
            className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 text-slate-950 font-extrabold text-sm shadow-lg shadow-emerald-500/25 transition-all flex items-center justify-center gap-2"
          >
            <span>العودة إلى التطبيق الرئيسي</span>
            <ExternalLink className="w-4 h-4" />
          </a>
        )}

        <div className="flex gap-2">
          <Link
            to="/history"
            className="flex-1 py-3 rounded-2xl bg-slate-800 hover:bg-slate-750 text-xs font-bold text-slate-200 border border-slate-700 text-center transition-colors"
          >
            سجل العمليات
          </Link>
          <Link
            to="/"
            className="flex-1 py-3 rounded-2xl bg-slate-800 hover:bg-slate-750 text-xs font-bold text-slate-200 border border-slate-700 text-center transition-colors"
          >
            الصفحة الرئيسية
          </Link>
        </div>
      </div>

    </div>
  );
};

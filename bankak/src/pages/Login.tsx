import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Landmark, ArrowRight, ShieldCheck, UserCheck, Lock, Smartphone, Sparkles, Zap } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { DEFAULT_USERS } from '../services/mockData';
import { firestoreService } from '../services/firestoreService';
import type { User } from '../types';

export const Login: React.FC = () => {
  const navigate = useNavigate();
  const { login, quickSwitch } = useAuth();
  
  const [identifier, setIdentifier] = useState('');
  const [pin, setPin] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isDemoLoading, setIsDemoLoading] = useState(false);
  const [allAccounts, setAllAccounts] = useState<User[]>(DEFAULT_USERS);

  useEffect(() => {
    firestoreService.getBankAccounts().then(accs => {
      if (accs && accs.length > 0) {
        setAllAccounts(accs.filter(a => a.id !== 'DEMO'));
      }
    });
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    const res = await login(identifier, pin);
    setIsLoading(false);
    if (res.success) {
      navigate('/');
    } else {
      setError(res.message || 'بيانات الدخول غير صحيحة');
    }
  };

  const handleQuickLogin = async (userId: string) => {
    await quickSwitch(userId);
    navigate('/');
  };

  const handleDemoLogin = async () => {
    setIsDemoLoading(true);
    await quickSwitch('DEMO');
    navigate('/');
  };

  return (
    <div className="min-h-screen flex flex-col justify-center items-center px-4 py-8 bg-slate-950 text-slate-100">
      
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-96 h-96 bg-emerald-600/10 rounded-full blur-3xl pointer-events-none" />

      <div className="w-full max-w-md relative z-10">
        
        {/* Logo */}
        <div className="text-center mb-6 animate-fade-in">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-3xl bg-gradient-to-tr from-emerald-600 to-teal-400 text-white shadow-xl shadow-emerald-600/25 mb-4 border border-emerald-400/30">
            <Landmark className="w-8 h-8" />
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
            تطبيق بنكك التجريبي
          </h1>
          <p className="text-sm text-slate-400 mt-1.5 max-w-xs mx-auto">
            محاكي بنكي متصل بتطبيق نظام المرور الذكي
          </p>
        </div>

        {/* DEMO Button - بارز في الأعلى */}
        <button
          onClick={handleDemoLogin}
          disabled={isDemoLoading}
          className="w-full mb-4 py-4 px-5 rounded-3xl bg-gradient-to-r from-emerald-500 via-teal-500 to-emerald-600 hover:from-emerald-400 hover:to-teal-400 text-white font-extrabold shadow-2xl shadow-emerald-500/30 active:scale-[0.99] transition-all flex items-center justify-between border border-emerald-400/30"
        >
          <div className="text-right">
            <div className="flex items-center gap-2 mb-0.5">
              <Zap className="w-5 h-5 text-yellow-300" />
              <span className="text-base">{isDemoLoading ? 'جاري الدخول...' : 'دخول تجريبي فوري'}</span>
            </div>
            <div className="text-xs text-emerald-100 opacity-80">
              حساب DEMO · رقم الحساب: <span className="font-mono font-bold">00000</span> · PIN: <span className="font-mono font-bold">0000</span>
            </div>
            <div className="text-xs text-yellow-300 font-mono font-bold mt-0.5">
              رصيد: 500,000.00 SDG
            </div>
          </div>
          <div className="bg-white/20 rounded-2xl p-2.5 flex-shrink-0">
            <ArrowRight className="w-5 h-5 rotate-180" />
          </div>
        </button>

        {/* Login Card */}
        <div className="glass-panel rounded-3xl p-6 sm:p-8 shadow-2xl border border-slate-800">
          
          <div className="text-xs font-bold text-slate-400 mb-4 text-center">— أو سجّل دخول بحسابك الخاص —</div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                رقم الهاتف أو رقم الحساب
              </label>
              <div className="relative">
                <input
                  type="text"
                  value={identifier}
                  onChange={e => setIdentifier(e.target.value)}
                  placeholder="مثال: 10019 أو 0909987296"
                  className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-sm placeholder-slate-500 focus:outline-none"
                  required
                />
                <Smartphone className="w-5 h-5 text-slate-400 absolute top-3.5 right-3.5" />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                رمز الـ PIN (4 أرقام)
              </label>
              <div className="relative">
                <input
                  type="password"
                  maxLength={4}
                  value={pin}
                  onChange={e => setPin(e.target.value)}
                  placeholder="••••"
                  className="w-full px-4 py-3 pr-11 rounded-2xl glass-input text-white text-sm placeholder-slate-500 tracking-widest focus:outline-none"
                  required
                />
                <Lock className="w-5 h-5 text-slate-400 absolute top-3.5 right-3.5" />
              </div>
            </div>

            {error && (
              <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs text-center">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={isLoading}
              className="w-full py-3.5 px-4 rounded-2xl bg-slate-700 hover:bg-slate-600 text-white font-bold text-sm active:scale-[0.99] transition-all flex items-center justify-center gap-2"
            >
              <span>{isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'}</span>
              <ArrowRight className="w-4 h-4 rotate-180" />
            </button>
          </form>

          {/* قائمة المستخدمين المسجلين */}
          <div className="mt-6 pt-5 border-t border-slate-800/80">
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-bold text-slate-300 flex items-center gap-1.5">
                <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                دخول سريع بحساب مستخدم
              </span>
              <span className="text-[11px] text-slate-500">PIN: 1234</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 max-h-52 overflow-y-auto pr-1">
              {allAccounts.map(demoUser => (
                <button
                  key={demoUser.id}
                  type="button"
                  onClick={() => handleQuickLogin(demoUser.id)}
                  className="text-right p-3 rounded-2xl bg-slate-800/50 hover:bg-slate-800 border border-slate-700/60 hover:border-emerald-500/40 transition-all group flex items-center justify-between"
                >
                  <div className="min-w-0">
                    <div className="text-xs font-bold text-slate-200 group-hover:text-emerald-300 transition-colors truncate">
                      {demoUser.name}
                    </div>
                    <div className="text-[10px] text-slate-400 mt-0.5 font-mono">
                      {demoUser.accountNumber || demoUser.phone}
                    </div>
                    <div className="text-[10px] text-emerald-400 font-mono font-semibold mt-0.5">
                      {Number(demoUser.balance || 0).toLocaleString('ar-SD')} SDG
                    </div>
                  </div>
                  <UserCheck className="w-4 h-4 text-slate-500 group-hover:text-emerald-400 transition-colors flex-shrink-0 ml-2" />
                </button>
              ))}
            </div>
          </div>

        </div>

        <div className="mt-6 text-center text-xs text-slate-500 flex items-center justify-center gap-1.5">
          <ShieldCheck className="w-4 h-4 text-emerald-500" />
          <span>بيئة وهمية آمنة لا تتعامل بأموال حقيقية</span>
        </div>

      </div>
    </div>
  );
};

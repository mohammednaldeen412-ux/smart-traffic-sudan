import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Landmark, Code2, Users, ShieldCheck, ChevronDown, RefreshCw } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { DEFAULT_USERS } from '../services/mockData';

export const Header: React.FC = () => {
  const { user, quickSwitch, resetAll } = useAuth();
  const [showSwitchMenu, setShowSwitchMenu] = useState(false);
  const location = useLocation();

  const isDevPage = location.pathname === '/developer';

  return (
    <header className="sticky top-0 z-40 w-full glass-panel border-b border-slate-800/80">
      <div className="max-w-4xl mx-auto px-4 h-16 flex items-center justify-between">
        
        {/* Logo & Brand */}
        <Link to="/" className="flex items-center gap-2.5 group">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-emerald-600 to-teal-400 flex items-center justify-center text-white shadow-lg shadow-emerald-500/20 group-hover:scale-105 transition-transform">
            <Landmark className="w-5 h-5" />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="font-extrabold text-lg text-white tracking-wide">بنكك</span>
              <span className="text-[10px] uppercase font-bold px-1.5 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                Mock
              </span>
            </div>
            <span className="text-[11px] text-slate-400 block -mt-0.5">بوابة الدفع والتطبيق البنكي</span>
          </div>
        </Link>

        {/* Right Actions: Switch Account + Dev Playground */}
        <div className="flex items-center gap-2">
          
          {/* Developer / Gateway Link */}
          <Link
            to="/developer"
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
              isDevPage
                ? 'bg-emerald-500 text-slate-950 font-bold shadow-md shadow-emerald-500/30'
                : 'bg-slate-800 text-slate-300 hover:bg-slate-700 hover:text-white border border-slate-700/60'
            }`}
          >
            <Code2 className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">مختبر الربط</span>
          </Link>

          {/* User Profile Switcher */}
          {user && (
            <div className="relative">
              <button
                type="button"
                onClick={() => setShowSwitchMenu(!showSwitchMenu)}
                className="flex items-center gap-2 py-1 px-2.5 rounded-xl bg-slate-800/80 hover:bg-slate-750 border border-slate-700/60 transition-colors"
              >
                <div className="w-7 h-7 rounded-full overflow-hidden bg-emerald-700 flex items-center justify-center text-xs font-bold text-white ring-1 ring-emerald-500/50">
                  {user.avatar ? (
                    <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
                  ) : (
                    user.name.slice(0, 1)
                  )}
                </div>
                <div className="text-right hidden sm:block">
                  <span className="text-xs font-semibold text-slate-200 block leading-tight">{user.name.split(' ')[0]}</span>
                  <span className="text-[10px] text-emerald-400">{user.role === 'merchant' ? 'تاجر' : 'شخصي'}</span>
                </div>
                <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
              </button>

              {/* Dropdown Menu */}
              {showSwitchMenu && (
                <div className="absolute left-0 mt-2 w-64 rounded-2xl bg-slate-900 border border-slate-700 shadow-2xl p-2 z-50 animate-slide-up">
                  <div className="px-3 py-2 border-b border-slate-800 mb-1">
                    <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider flex items-center gap-1">
                      <Users className="w-3 h-3" />
                      تبديل الحساب التجريبي
                    </span>
                  </div>

                  <div className="space-y-1">
                    {DEFAULT_USERS.map(u => (
                      <button
                        key={u.id}
                        onClick={() => {
                          quickSwitch(u.id);
                          setShowSwitchMenu(false);
                        }}
                        className={`w-full text-right flex items-center justify-between p-2 rounded-xl text-xs transition-colors ${
                          user.id === u.id
                            ? 'bg-emerald-950/50 text-emerald-300 font-semibold border border-emerald-800/40'
                            : 'hover:bg-slate-800 text-slate-300'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-slate-700 flex items-center justify-center text-[10px] font-bold">
                            {u.name.slice(0, 1)}
                          </div>
                          <div>
                            <div>{u.name}</div>
                            <div className="text-[10px] text-slate-400">{u.role === 'merchant' ? 'حساب تاجر' : 'حساب شخصي'}</div>
                          </div>
                        </div>
                        {user.id === u.id && <ShieldCheck className="w-4 h-4 text-emerald-400" />}
                      </button>
                    ))}
                  </div>

                  <div className="mt-2 pt-2 border-t border-slate-800">
                    <button
                      onClick={() => {
                        resetAll();
                        setShowSwitchMenu(false);
                      }}
                      className="w-full flex items-center justify-center gap-1.5 py-1.5 rounded-lg text-xs text-rose-400 hover:bg-rose-950/30 transition-colors"
                    >
                      <RefreshCw className="w-3 h-3" />
                      <span>إعادة تعيين البيانات الافتراضية</span>
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

        </div>

      </div>
    </header>
  );
};

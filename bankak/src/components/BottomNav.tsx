import React from 'react';
import { NavLink } from 'react-router-dom';
import { Home, ArrowLeftRight, History as HistoryIcon, User, CreditCard } from 'lucide-react';

export const BottomNav: React.FC = () => {
  const navItems = [
    { to: '/', label: 'الرئيسية', icon: Home },
    { to: '/transfer', label: 'تحويل', icon: ArrowLeftRight },
    { to: '/pay', label: 'الدفع', icon: CreditCard },
    { to: '/history', label: 'السجل', icon: HistoryIcon },
    { to: '/profile', label: 'حسابي', icon: User },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-slate-900/90 backdrop-blur-lg border-t border-slate-800/80 px-2 py-1.5 sm:hidden">
      <div className="flex items-center justify-around max-w-md mx-auto">
        {navItems.map(item => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                `flex flex-col items-center justify-center py-1 px-3 rounded-2xl transition-all duration-200 ${
                  isActive
                    ? 'text-emerald-400 font-bold scale-105'
                    : 'text-slate-400 hover:text-slate-200'
                }`
              }
            >
              <Icon className="w-5 h-5 mb-0.5" />
              <span className="text-[10px]">{item.label}</span>
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
};

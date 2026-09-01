import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { WalletProvider } from './context/WalletContext';
import { Header } from './components/Header';
import { BottomNav } from './components/BottomNav';

import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { Transfer } from './pages/Transfer';
import { PaymentGateway } from './pages/PaymentGateway';
import { Receipt } from './pages/Receipt';
import { History } from './pages/History';
import { Profile } from './pages/Profile';
import { DeveloperDocs } from './pages/DeveloperDocs';

const AppLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col selection:bg-emerald-500 selection:text-white font-sans">
      <Header />
      <main className="flex-1 max-w-4xl w-full mx-auto px-4 pt-6 pb-24 sm:pb-12">
        {children}
      </main>
      <BottomNav />
    </div>
  );
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <WalletProvider>
        <BrowserRouter>
          <Routes>
            {/* Public Auth Screen */}
            <Route path="/login" element={<Login />} />

            {/* Main App Screens wrapped in Layout */}
            <Route
              path="/"
              element={
                <AppLayout>
                  <Dashboard />
                </AppLayout>
              }
            />
            <Route
              path="/transfer"
              element={
                <AppLayout>
                  <Transfer />
                </AppLayout>
              }
            />
            <Route
              path="/pay"
              element={
                <AppLayout>
                  <PaymentGateway />
                </AppLayout>
              }
            />
            <Route
              path="/receipt/:id"
              element={
                <AppLayout>
                  <Receipt />
                </AppLayout>
              }
            />
            <Route
              path="/history"
              element={
                <AppLayout>
                  <History />
                </AppLayout>
              }
            />
            <Route
              path="/profile"
              element={
                <AppLayout>
                  <Profile />
                </AppLayout>
              }
            />
            <Route
              path="/developer"
              element={
                <AppLayout>
                  <DeveloperDocs />
                </AppLayout>
              }
            />

            {/* Fallback */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </WalletProvider>
    </AuthProvider>
  );
};

export default App;

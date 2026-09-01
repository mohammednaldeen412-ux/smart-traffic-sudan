import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Code2, 
  Play, 
  Copy, 
  Check, 
  Terminal, 
  BookOpen, 
  ArrowRight,
  Globe,
  Smartphone,
  Server,
  Layers
} from 'lucide-react';
import { gatewayService } from '../services/gatewayService';
import type { PaymentRequest } from '../types';

export const DeveloperDocs: React.FC = () => {
  const navigate = useNavigate();

  // Test form state
  const [merchant, setMerchant] = useState('متجر إلكتروني تجريبي');
  const [amount, setAmount] = useState('2500');
  const [currency, setCurrency] = useState('SDG');
  const [orderId, setOrderId] = useState('ORD-7741');
  const [description, setDescription] = useState('دفع قيمة طلبية من التطبيق الرئيسي');
  const [callbackUrl, setCallbackUrl] = useState('https://myapp.example.com/checkout/callback');

  const [copiedUrl, setCopiedUrl] = useState(false);
  const [activeTab, setActiveTab] = useState<'js' | 'flutter' | 'react' | 'backend'>('js');

  const currentPaymentReq: PaymentRequest = {
    merchant,
    amount: parseFloat(amount) || 0,
    currency,
    order_id: orderId,
    description,
    callback_url: callbackUrl,
  };

  const generatedUrl = gatewayService.generatePaymentLink(currentPaymentReq);

  const copyUrl = () => {
    navigator.clipboard.writeText(generatedUrl);
    setCopiedUrl(true);
    setTimeout(() => setCopiedUrl(false), 2000);
  };

  const handleTestRedirect = () => {
    const urlObj = new URL(generatedUrl);
    navigate(`${urlObj.pathname}${urlObj.search}`);
  };

  const codeSnippets = {
    js: `// طريقة 1: توجيه العميل مباشرة إلى بوابة دفع بنكك عبر JavaScript
function redirectToBankakPayment() {
  const params = new URLSearchParams({
    merchant: "${merchant}",
    amount: "${amount}",
    currency: "${currency}",
    order_id: "${orderId}",
    description: "${description}",
    callback_url: "${callbackUrl}"
  });

  window.location.href = "${window.location.origin}/pay?" + params.toString();
}`,
    react: `// طريقة 2: استخدام React في تطبيقك الرئيسي
import React from 'react';

export const CheckoutButton = ({ order, totalAmount }) => {
  const handlePayWithBankak = () => {
    const gatewayUrl = "${window.location.origin}/pay";
    const search = new URLSearchParams({
      merchant: "${merchant}",
      amount: totalAmount.toString(),
      currency: "SDG",
      order_id: order.id,
      description: "طلب رقم " + order.id,
      callback_url: window.location.origin + "/order-success"
    });

    window.location.href = \`\${gatewayUrl}?\${search.toString()}\`;
  };

  return (
    <button 
      onClick={handlePayWithBankak}
      className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold py-3 px-6 rounded-xl flex items-center gap-2"
    >
      الدفع عبر بنكك
    </button>
  );
};`,
    flutter: `// طريقة 3: Flutter / Dart (Mobile App)
import 'package:url_launcher/url_launcher.dart';

void openBankakPayment({required String orderId, required double amount}) async {
  final uri = Uri.parse('${window.location.origin}/pay').replace(
    queryParameters: {
      'merchant': '${merchant}',
      'amount': amount.toString(),
      'currency': 'SDG',
      'order_id': orderId,
      'description': 'دفع طلبية رقم \$orderId',
      'callback_url': 'myapp://payment-callback',
    },
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}`,
    backend: `// طريقة 4: معالجة الـ Callback في الـ Backend عند نجاح الدفع (Node.js / Express)
app.get('/checkout/callback', (req, res) => {
  const { status, txn_id, order_id, amount, reference, signature } = req.query;

  if (status === 'success') {
    // 1. تحديث حالة الطلب في قاعدة البيانات إلى "مدفوع"
    // await updateOrderStatus(order_id, 'PAID', { txn_id, reference });

    console.log(\`✅ تم استلام دفعة بنجاح للطلب \${order_id}, المعاملة: \${txn_id}\`);
    return res.redirect(\`/success?order=\${order_id}\`);
  } else {
    return res.redirect(\`/failed?order=\${order_id}\`);
  }
});`
  };

  return (
    <div className="max-w-3xl mx-auto space-y-8 pb-20 sm:pb-8 animate-fade-in">
      
      {/* Top Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/')}
            className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-extrabold text-white flex items-center gap-2">
              <Code2 className="w-5 h-5 text-emerald-400" />
              مختبر وتوثيق ربط بوابة الدفع (Integration Playground)
            </h1>
            <p className="text-xs text-slate-400">
              دليل الربط بين تطبيقك الرئيسي وتطبيق بنكك التجريبي
            </p>
          </div>
        </div>
      </div>

      {/* Simulator Card */}
      <div className="glass-panel rounded-3xl p-6 sm:p-8 border border-slate-800 space-y-6 shadow-2xl">
        
        <div className="flex items-center justify-between border-b border-slate-800 pb-4">
          <div>
            <h2 className="text-base font-bold text-white flex items-center gap-2">
              <Terminal className="w-4 h-4 text-teal-400" />
              مُوَلّد طلبات الدفع التفاعلي (Interactive Request Builder)
            </h2>
            <p className="text-xs text-slate-400 mt-0.5">
              قم بتعديل الحقول أدناه لتوليد رابط دفع مخصص واختباره مباشرة
            </p>
          </div>
        </div>

        {/* Inputs Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
          
          <div>
            <label className="block font-semibold text-slate-300 mb-1">اسم التاجر / التطبيق (merchant)</label>
            <input
              type="text"
              value={merchant}
              onChange={e => setMerchant(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl glass-input text-white"
            />
          </div>

          <div>
            <label className="block font-semibold text-slate-300 mb-1">المبلغ المطلوب (amount)</label>
            <input
              type="number"
              value={amount}
              onChange={e => setAmount(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl glass-input text-white font-bold"
            />
          </div>

          <div>
            <label className="block font-semibold text-slate-300 mb-1">رقم الطلب الفريد (order_id)</label>
            <input
              type="text"
              value={orderId}
              onChange={e => setOrderId(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl glass-input text-white font-mono"
            />
          </div>

          <div>
            <label className="block font-semibold text-slate-300 mb-1">العملة (currency)</label>
            <select
              value={currency}
              onChange={e => setCurrency(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl glass-input text-white bg-slate-900"
            >
              <option value="SDG">SDG (جنيه سوداني)</option>
              <option value="USD">USD (دولار)</option>
              <option value="SAR">SAR (ريال سعودي)</option>
            </select>
          </div>

          <div className="sm:col-span-2">
            <label className="block font-semibold text-slate-300 mb-1">وصف العملية / الفاتورة (description)</label>
            <input
              type="text"
              value={description}
              onChange={e => setDescription(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl glass-input text-white"
            />
          </div>

          <div className="sm:col-span-2">
            <label className="block font-semibold text-slate-300 mb-1">رابط الرجوع بعد الدفع (callback_url)</label>
            <input
              type="url"
              value={callbackUrl}
              onChange={e => setCallbackUrl(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl glass-input text-white font-mono text-[11px]"
            />
          </div>

        </div>

        {/* Live Generated URL Box */}
        <div className="p-4 rounded-2xl bg-slate-950 border border-slate-800 space-y-3">
          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-400 font-semibold flex items-center gap-1.5">
              <Globe className="w-4 h-4 text-emerald-400" />
              الرابط المولد للدفع (Payment Link):
            </span>
            <button
              onClick={copyUrl}
              className="flex items-center gap-1 text-emerald-400 hover:text-emerald-300 font-bold"
            >
              {copiedUrl ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
              <span>{copiedUrl ? 'تم النسخ!' : 'نسخ الرابط'}</span>
            </button>
          </div>

          <div className="p-3 rounded-xl bg-slate-900/90 border border-slate-800 text-[11px] font-mono text-emerald-300 break-all select-all">
            {generatedUrl}
          </div>

          <div className="flex gap-2 pt-2">
            <button
              onClick={handleTestRedirect}
              className="flex-1 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-extrabold text-xs shadow-lg shadow-emerald-500/20 transition-all flex items-center justify-center gap-2"
            >
              <Play className="w-4 h-4 fill-current" />
              <span>تجربة فتح شاشة الدفع الآن</span>
            </button>
          </div>
        </div>

      </div>

      {/* Code Examples Section */}
      <div className="glass-panel rounded-3xl p-6 sm:p-8 border border-slate-800 space-y-4">
        <h2 className="text-base font-bold text-white flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-emerald-400" />
          أمثلة كود برمجية جاهزة للربط
        </h2>

        {/* Code Tabs */}
        <div className="flex items-center gap-2 border-b border-slate-800 pb-2">
          {[
            { id: 'js', label: 'JavaScript / Web', icon: Globe },
            { id: 'react', label: 'React.js', icon: Layers },
            { id: 'flutter', label: 'Flutter / Mobile', icon: Smartphone },
            { id: 'backend', label: 'Node.js Backend (Callback)', icon: Server },
          ].map(tab => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 transition-all ${
                  activeTab === tab.id
                    ? 'bg-slate-800 text-emerald-400 border border-slate-700'
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                <Icon className="w-3.5 h-3.5" />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </div>

        {/* Code View */}
        <div className="relative">
          <pre className="p-4 rounded-2xl bg-slate-950 border border-slate-800 text-xs font-mono text-slate-200 overflow-x-auto text-left dir-ltr leading-relaxed">
            <code>{codeSnippets[activeTab]}</code>
          </pre>
          <button
            onClick={() => {
              navigator.clipboard.writeText(codeSnippets[activeTab]);
              alert('تم نسخ الكود!');
            }}
            className="absolute top-3 right-3 p-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-300 text-xs flex items-center gap-1 border border-slate-700"
          >
            <Copy className="w-3.5 h-3.5" />
            <span>نسخ الكود</span>
          </button>
        </div>
      </div>

      {/* API Parameters Reference Table */}
      <div className="glass-panel rounded-3xl p-6 sm:p-8 border border-slate-800 space-y-4">
        <h2 className="text-base font-bold text-white">جدول المتغيرات والمعاملات المدعومة</h2>

        <div className="overflow-x-auto">
          <table className="w-full text-xs text-right border-collapse">
            <thead>
              <tr className="border-b border-slate-800 text-slate-400">
                <th className="py-2.5 px-3 font-semibold">المعامل (Parameter)</th>
                <th className="py-2.5 px-3 font-semibold">النوع</th>
                <th className="py-2.5 px-3 font-semibold">إلزامي؟</th>
                <th className="py-2.5 px-3 font-semibold">الوصف</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 text-slate-300">
              <tr>
                <td className="py-2.5 px-3 font-mono text-emerald-400">merchant</td>
                <td className="py-2.5 px-3 text-slate-400">string</td>
                <td className="py-2.5 px-3 text-emerald-400">نعم</td>
                <td className="py-2.5 px-3">اسم متجرك أو تطبيقك الذي يظهر للعميل</td>
              </tr>
              <tr>
                <td className="py-2.5 px-3 font-mono text-emerald-400">amount</td>
                <td className="py-2.5 px-3 text-slate-400">number</td>
                <td className="py-2.5 px-3 text-emerald-400">نعم</td>
                <td className="py-2.5 px-3">مبلغ الفاتورة المراد خصمه</td>
              </tr>
              <tr>
                <td className="py-2.5 px-3 font-mono text-emerald-400">order_id</td>
                <td className="py-2.5 px-3 text-slate-400">string</td>
                <td className="py-2.5 px-3 text-emerald-400">نعم</td>
                <td className="py-2.5 px-3">رقم الطلب الفريد في نظام تطبيقك</td>
              </tr>
              <tr>
                <td className="py-2.5 px-3 font-mono text-emerald-400">callback_url</td>
                <td className="py-2.5 px-3 text-slate-400">url</td>
                <td className="py-2.5 px-3 text-slate-400">اختياري</td>
                <td className="py-2.5 px-3">الرابط الذي يتم إرجاع المستخدم إليه مصحوباً بنتيجة الدفع</td>
              </tr>
              <tr>
                <td className="py-2.5 px-3 font-mono text-emerald-400">description</td>
                <td className="py-2.5 px-3 text-slate-400">string</td>
                <td className="py-2.5 px-3 text-slate-400">اختياري</td>
                <td className="py-2.5 px-3">شرح أو تفاصيل الطلب تظهر تحت المبلغ</td>
              </tr>
              <tr>
                <td className="py-2.5 px-3 font-mono text-emerald-400">currency</td>
                <td className="py-2.5 px-3 text-slate-400">string</td>
                <td className="py-2.5 px-3 text-slate-400">اختياري</td>
                <td className="py-2.5 px-3">العملة (الافتراضي SDG)</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

    </div>
  );
};

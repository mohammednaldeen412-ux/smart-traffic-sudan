# 🚦 نظام المرور الذكي الشامل - جمهورية السودان
### Smart Traffic Sudan System (Ecosystem)

منظومة متكاملة ذكية لإدارة المرور والمخالفات وسدادها إلكترونياً، تربط بين **المواطنين**، **ضباط الميدان**، **الإدارة العامة للمرور**، و**البنوك السودانية (بنكك)** عبر خوادم سحابية وقاعدة بيانات موحدة وفورية.

---

## 🌐 روابط الأنظمة المنشورة أونلاين (Live Demos)

| النظام / الموقع | التقنية المستخدمة | رابط الوصول المباشر |
| :--- | :--- | :--- |
| 🛡️ **لوحة تحكم الإدارة العامة للمرور (Admin Dashboard)** | Flutter Web + Firebase | [https://smart-traffic-sudan.web.app](https://smart-traffic-sudan.web.app) |
| 🏦 **بوابة ومحاكي بنكك للدفع الإلكتروني (Bankak Gateway)** | React + TypeScript + Vite | [https://smart-traffic-bankak.web.app](https://smart-traffic-bankak.web.app) |

---

## 🏗️ هيكلية المنظومة (Monorepo Structure)

المشروع مبني بهيكلية **Monorepo** موحدة تضم ثلاثة مكونات رئيسية:

```
smart-traffic-sudan/
│
├── 📱 moror/                 # تطبيق الهاتف المحمول (Flutter Mobile App)
│   ├── lib/                  # كود التطبيق (المواطن + الضابط الميداني)
│   ├── android/              # إعدادات وتشغيل الأندرويد
│   └── pubspec.yaml          # حزم واعتمادات Flutter
│
├── 🛡️ smart_traffic_admin/    # لوحة تحكم المرور المركزية (Flutter Web)
│   ├── lib/                  # واجهات الإحصائيات، إدارة المخالفات والتقارير
│   └── firebase.json         # إعدادات استضافة Firebase Hosting
│
├── 🏦 bankak/                 # محاكي وبوابة دفع بنكك (React Web App)
│   ├── src/                  # واجهات الحسابات، التحويلات، وتأكيد الدفع
│   ├── package.json          # اعتمادات Vite و React و Firebase
│   └── deploy_bankak.bat     # سكربت النشر التلقائي
│
└── 📄 README.md              # دليل التوثيق والتشغيل الشامل
```

---

## ✨ أبرز الميزات والوظائف

### 1. تطبيق المرور (`moror` - Flutter):
* **واجهة المواطن**:
  * استعلام لحظي عن المخالفات المرورية المسجلة على المركبة أو رخصة القيادة.
  * سداد المخالفات فورياً عبر بوابة **بنكك** بخصم لحظي وتوليد إيصال مالي إلكتروني معتمد.
  * تقديم طلبات الاعتراض والطعون على المخالفات مع إرفاق المبررات.
  * استلام إشعارات فورية عبر (Firebase Cloud Messaging).
* **واجهة ضابط المرور الميداني**:
  * رصد وتسجيل المخالفات المرورية ميدانياً وتصوير اللوحات.
  * الاستعلام عن بيانات اللوحات وسجل السائق فورياً.
  * متابعة نوبة العمل الميدانية والإحصائيات الخاصة بها.

### 2. لوحة تحكم الإدارة العامة للمرور (`smart_traffic_admin` - Flutter Web):
* إدارة شاملة لجميع المخالفات وحالات السداد.
* متابعة وفصل الاعتراضات والطعون المقدمة من المواطنين.
* إحصائيات بيانية وتقارير متقدمة عن القطاعات ونسب التحصيل.
* إدارة حسابات الضباط وتحديد القطاعات الميدانية.

### 3. بوابة ومحاكي بنكك (`bankak` - React):
* محاكي مصرفي كامل لحسابات بنك الخرطوم (بنكك).
* مزامنة حية لحظية مع تطبيق المرور عبر **Firestore Atomic Transactions**.
* إمكانية إدارة الحسابات وتتبع سجل المعاملات والإيصالات.

---

## 👥 فريق العمل وتوزيع المهام (Development Team & Task Allocation)

### 👨‍💻 1. م. محمد نصر الدين (Team Leader & Mobile App Architect)
* **المسؤوليات والمهام**:
  * التصميم المعماري العام للمنظومة وهيكلية الـ Monorepo.
  * تطوير وبرمجة تطبيق الهاتف الذكي (`moror`) عبر Flutter (واجهات المواطنين وضباط المرور).
  * تكامل ميزات الضبط الميداني، رصد المخالفات، واستعلام لوحات المركبات.
  * إدارة استضافة السيرفرات السحابية ونشر المشاريع على Firebase Hosting.

---

### 👨‍💻 2. م. مصطفى عيسى (Backend & Database Security Specialist)
* **المسؤوليات والمهام**:
  * تصميم وبناء هيكلية قاعدة البيانات السحابية (Firebase Cloud Firestore).
  * برمجة قواعد الحماية وصلاحيات الأدوار (Security Rules & Authentication).
  * تطوير المعاملات المالية الذرية (Atomic Transactions) وتشفير الإيصالات المالية (SHA-256 Hash).
  * إعداد وضبط خدمة الإشعارات التنبيهية الفورية (Cloud Messaging).

---

### 👨‍💻 3. م. علي عبد الرحمن (Web Gateways & QA Specialist)
* **المسؤوليات والمهام**:
  * تطوير وتصميم بوابة ومحاكي بنكك للدفع الإلكتروني (`Bankak`) عبر React + TypeScript.
  * تطوير واجهات لوحة تحكم وإدارة المرور العامة (`smart_traffic_admin`) عبر Flutter Web.
  * ربط واختبار تدفق عمليات الدفع الإلكتروني والمزامنة اللحظية بين البنك والتطبيق.
  * اختبار الجودة وفحص الأداء الشامل للأنظمة (Quality Assurance & End-to-End Testing).

---

## 🛠️ التقنيات المستخدمة (Tech Stack)
* **Frontend Mobile & Admin**: Flutter, Dart, Provider
* **Frontend Banking**: React 18, TypeScript, Vite, Tailwind CSS, Lucide Icons
* **Backend & Cloud**: Google Firebase (Firestore Database, Firebase Authentication, Firebase Hosting, Cloud Messaging)
* **Security & Transactions**: Atomic Firestore Transactions, SHA-256 Verification Hashing

---

## 🌐 المستودع الرسمي على GitHub
👉 [https://github.com/mohammednaldeen412-ux/smart-traffic-sudan](https://github.com/mohammednaldeen412-ux/smart-traffic-sudan)

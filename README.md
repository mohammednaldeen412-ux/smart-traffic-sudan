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

## 👥 فريق العمل والمطورين (Development Team)

<table align="center" width="100%">
  <tr>
    <td align="center" width="33%" valign="top">
      <img src="docs/team/mohammed.jpg" width="170" height="220" style="border-radius: 18px; object-fit: cover;" alt="م. محمد نصر الدين"/><br /><br />
      <b>م. محمد نصر الدين</b><br />
      <sub>قائد الفريق ومطور تطبيق الهاتف</sub><br /><br />
      <a href="https://wa.me/249961941263">💬 واتساب: 0961941263</a>
      <br /><br />
      <details>
        <summary><b>📋 عرض تفاصيل المهام</b></summary>
        <div align="right">
          <ul>
            <li>التخطيط المعماري العام للمنظومة وهيكلية الـ Monorepo.</li>
            <li>تطوير وبرمجة تطبيق الموبايل (<code>moror</code>) عبر Flutter.</li>
            <li>بناء وتطوير واجهات المواطنين وضباط المرور الميدانيين.</li>
            <li>إدارة الاستضافة السحابية ونشر المشاريع على Firebase.</li>
          </ul>
        </div>
      </details>
    </td>
    <td align="center" width="33%" valign="top">
      <img src="docs/team/mustafa.jpg" width="170" height="220" style="border-radius: 18px; object-fit: cover;" alt="م. مصطفى عيسى"/><br /><br />
      <b>م. مصطفى عيسى</b><br />
      <sub>مهندس الخوادم وقواعد البيانات والأمان</sub><br /><br />
      <a href="https://wa.me/249909987293">💬 واتساب: 0909987293</a>
      <br /><br />
      <details>
        <summary><b>📋 عرض تفاصيل المهام</b></summary>
        <div align="right">
          <ul>
            <li>تصميم وبناء هيكلية قاعدة البيانات (Cloud Firestore).</li>
            <li>إعداد وبرمجة قواعد الحماية وصلاحيات الأدوار (Security Rules).</li>
            <li>برمجة المعاملات المالية الذرية (Atomic Transactions).</li>
            <li>تطبيق خوارزميات التشفير وإعداد الإشعارات (Cloud Messaging).</li>
          </ul>
        </div>
      </details>
    </td>
    <td align="center" width="33%" valign="top">
      <img src="docs/team/ali.jpg" width="170" height="220" style="border-radius: 18px; object-fit: cover;" alt="م. علي عبد الرحمن"/><br /><br />
      <b>م. علي عبد الرحمن</b><br />
      <sub>مطور واجهات الويب وبوابة الدفع واختبار الجودة</sub><br /><br />
      <a href="https://wa.me/249960402145">💬 واتساب: 0960402145</a>
      <br /><br />
      <details>
        <summary><b>📋 عرض تفاصيل المهام</b></summary>
        <div align="right">
          <ul>
            <li>تصميم وبناء بوابة ومحاكي بنكك (React + TypeScript).</li>
            <li>تطوير لوحة تحكم إدارة المرور (Flutter Web).</li>
            <li>ربط وتجربة تدفق عمليات السداد الإلكتروني والمزامنة.</li>
            <li>اختبار الأداء وفحص الجودة الشامل للأنظمة (QA Testing).</li>
          </ul>
        </div>
      </details>
    </td>
  </tr>
</table>

---

## 🛠️ التقنيات المستخدمة (Tech Stack)
* **Frontend Mobile & Admin**: Flutter, Dart, Provider
* **Frontend Banking**: React 18, TypeScript, Vite, Tailwind CSS, Lucide Icons
* **Backend & Cloud**: Google Firebase (Firestore Database, Firebase Authentication, Firebase Hosting, Cloud Messaging)
* **Security & Transactions**: Atomic Firestore Transactions, SHA-256 Verification Hashing

---

## 🌐 المستودع الرسمي على GitHub
👉 [https://github.com/mohammednaldeen412-ux/smart-traffic-sudan](https://github.com/mohammednaldeen412-ux/smart-traffic-sudan)

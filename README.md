# 🚦 نظام المرور الذكي الشامل - جمهورية السودان
### Smart Traffic Sudan Ecosystem (V3 - النسخة النهائية)

منظومة متكاملة ذكية لإدارة المرور والمخالفات وسدادها إلكترونياً، تربط بين **المواطنين**، **ضباط الميدان**، **الإدارة العامة للمرور**، و**البنوك السودانية (بنكك)** عبر خوادم سحابية وقاعدة بيانات موحدة وفورية.

---

## 📲 تحميل التطبيق (النسخة الحالية V3)

<div align="center">
  <br />
  <a href="https://github.com/mohammednaldeen412-ux/smart-traffic-sudan/raw/main/apk/app-release.apk">
    <img src="https://img.shields.io/badge/📥_تحميل_تطبيق_المرور_الآن-Android_APK-2ea44f?style=for-the-badge&logo=android&logoColor=white" alt="تحميل التطبيق" height="75" />
  </a>
  <br /><br />
</div>

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

## 🌟 الدليل الشامل لمستخدمي النظام (User Roles & Features)

التطبيق مصمم ليخدم جميع فئات المستخدمين بصلاحيات وواجهات مخصصة تضمن الكفاءة والأمان:

### 👤 1. واجهة المواطن (Citizen App)
الواجهة المخصصة لخدمة المواطنين وتسهيل إجراءاتهم المرورية من هواتفهم مباشرة:
* **الاستعلام الفوري:** التحقق اللحظي من المخالفات المسجلة على المركبة أو رخصة القيادة.
* **السداد الإلكتروني الآمن:** سداد الغرامات فورياً عبر بوابة **بنكك (Bankak)** المدمجة، مع الخصم اللحظي وإصدار إيصال إلكتروني معتمد.
* **تقديم الاعتراضات:** إمكانية تقديم طعون أو اعتراضات على المخالفات المحررة مع إرفاق الأدلة والصور، ومتابعة حالة الطلب.
* **طوارئ المرور (SOS 777):** زر نداء طوارئ ذكي يرسل إحداثيات الموقع (GPS) لحظياً لغرفة العمليات لطلب التدخل السريع.
* **رخصة القيادة الرقمية:** استعراض بيانات الرخصة وصلاحيتها رقمياً في أي وقت.

### 👮‍♂️ 2. واجهة ضابط المرور الميداني (Field Officer App)
أداة العمل الرئيسية لرجال المرور في الشارع لضمان الدقة والسرعة:
* **تحرير المخالفات الرقمية:** تسجيل المخالفات ميدانياً وتصوير اللوحات وربطها آلياً بقاعدة البيانات المركزية.
* **الفحص اللحظي:** الاستعلام السريع عن بيانات المركبات وسجل السائقين للتأكد من صحة التراخيص وعدم وجود بلاغات سرقة.
* **متابعة المهام:** تسجيل الحضور الميداني ومتابعة إحصائيات المخالفات التي تم ضبطها خلال وردية العمل.

### 🛡️ 3. لوحة تحكم الإدارة العامة للمرور والأدمن (Admin Web Dashboard)
غرفة العمليات المركزية لإدارة المنظومة بالكامل (منصة ويب):
* **الإدارة الشاملة:** مراقبة جميع المخالفات المحررة وحالات السداد عبر كافة القطاعات.
* **إدارة النزاعات:** استعراض اعتراضات المواطنين والبت فيها (قبول/رفض) بناءً على الأدلة المرفقة.
* **خريطة الطوارئ الحية:** شاشة تتبع لحظية تظهر بلاغات الطوارئ (SOS) على الخريطة لتوجيه أقرب دورية للموقع.
* **التقارير والإحصائيات:** لوحات بيانية متقدمة (Charts) تحلل نسب التحصيل، أنواع المخالفات الشائعة، وتقييم أداء الضباط والقطاعات.
* **إدارة الصلاحيات:** التحكم بحسابات الضباط، المواطنين، وتوزيع القطاعات الميدانية.

### 🏦 4. بوابة ومحاكي البنك (Bankak Gateway)
نظام مستقل يحاكي العمليات المصرفية لضمان موثوقية الدفع:
* **مزامنة ذرية (Atomic Transactions):** تأكيد خصم المبلغ من حساب المواطن وإغلاق المخالفة في المرور في معاملة برمجية واحدة تمنع أي أخطاء محاسبية.
* **الإيصالات الإلكترونية:** توليد أرقام إيصالات مرجعية يمكن التحقق منها.

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

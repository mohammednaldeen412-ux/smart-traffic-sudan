# خطة تنفيذ نظام مرور السودان الذكي (ولاية النيل الأبيض)

هذه الخطة تهدف لتحويل التطبيق من نموذج تجريبي إلى نظام متكامل (End-to-End) مربوط ببيانات حقيقية وقواعد بيانات سحابية (Firebase) مع الالتزام بالهوية البصرية الحالية.

## متطلبات المراجعة

> [!IMPORTANT]
> - **إشعارات Push**: تتطلب إعداد ملف `google-services.json` مع تفعيل Cloud Messaging في Firebase Console.
> - **خدمة البريد (OTP)**: سنعتمد على Firebase Auth للتحقق من البريد. للـ OTP المخصص (كود رقمي)، يفضل استخدام Firebase Cloud Functions (يتطلب خطة Blaze).
> - **الدفع الإلكتروني**: سنقوم بتجهيز التدفق (Flow) وربطه بـ API تجريبي يحاكي استجابة البنوك السودانية (مثل Fawry أو Bankak Webhook).

## التغييرات المقترحة

### 1. قاعدة البيانات والتحقق (Firestore)
إعادة هيكلة Firestore لضمان العلاقات الصحيحة ومنع التكرار برمجياً وعبر القواعد (Rules).

#### [MODIFY] [traffic_service.dart](file:///C:/Users/DATA/Desktop/moror/lib/core/services/traffic_service.dart)
- إضافة منطق التحقق من (رقم اللوحة/الشاسيه) قبل الإضافة.
- ربط المخالفات بمحليات ولاية النيل الأبيض (كوسني، ربك، الدويم، إلخ).
- تنفيذ نظام الـ Audit Logs لتسجيل العمليات الحساسة.

#### [NEW] [firestore.rules](file:///C:/Users/DATA/Desktop/moror/firestore.rules)
- كتابة قواعد حماية تمنع المواطن من تعديل حالة الدفع أو كتابة مخالفات.
- ضمان فرادة رقم اللوحة عبر القيود السحابية.

### 2. نظام الهوية والأمان (Authentication)
تفعيل التحقق الحقيقي من البيانات الشخصية.

#### [MODIFY] [auth_service.dart](file:///C:/Users/DATA/Desktop/moror/lib/core/services/auth_service.dart)
- إضافة `sendEmailVerification` عند التسجيل.
- منع الدخول إلا للبريد الموثق (Verified Email).
- دعم رفع صور الملف الشخصي والمستندات إلى Firebase Storage.

### 3. نظام الإشعارات والتعاميم (Notifications & Announcements)
تفعيل التواصل اللحظي بين الإدارة والضباط والمواطنين.

#### [NEW] [notification_service.dart](file:///C:/Users/DATA/Desktop/moror/lib/core/services/notification_service.dart)
- إعداد مكتبة `firebase_messaging`.
- التعامل مع الإشعارات في الخلفية (Background) وعند فتح التطبيق.

#### [NEW] [announcement_model.dart](file:///C:/Users/DATA/Desktop/moror/lib/models/announcement_model.dart)
- نموذج لبيانات التعاميم الإدارية للضباط.

### 4. واجهة الإدارة (Admin Dashboard)
إضافة صلاحيات وواجهات جديدة للمسؤولين.

#### [NEW] [admin_navigation_wrapper.dart](file:///C:/Users/DATA/Desktop/moror/lib/screens/admin/admin_navigation_wrapper.dart)
- لوحة تحكم لمراجعة التقارير، إدارة الضباط، وإرسال التعاميم.

### 5. الملف الشخصي والمستندات (Profile & Documents)
توسيع خيارات المواطن لإدارة بياناته.

#### [MODIFY] [profile_settings_screen.dart](file:///C:/Users/DATA/Desktop/moror/lib/screens/profile/profile_settings_screen.dart)
- إضافة خيار تغيير كلمة المرور ورفع صور المستندات (الرخصة/البطاقة).

---

## خطة التحقق

### الاختبارات المؤتمتة
- `flutter test`: اختبار منع إضافة مركبة مكررة.
- اختبار صحة تحويل الـ JSON للنماذج الجديدة.

### التحقق اليدوي
- تجربة تسجيل حساب جديد ببريد حقيقي والتأكد من وصول رسالة التفعيل.
- إضافة مركبة موجودة مسبقاً والتأكد من ظهور رسالة الخطأ من السيرفر.
- إرسال تعميم من واجهة الإدارة والتأكد من وصول إشعار لجهاز الضابط.
- محاكاة عملية دفع والتأكد من تحديث الحالة في Firestore والـ Audit Log.

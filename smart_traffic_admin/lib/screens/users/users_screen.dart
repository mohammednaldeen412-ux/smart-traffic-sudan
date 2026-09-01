import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Text('إدارة المستخدمين',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F))),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddOfficerDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة ضابط جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث بالاسم أو البريد...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                
                var docs = snap.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['fullName'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) return const Center(child: Text('لا توجد نتائج مطابقة'));
                return Card(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F4F8)),
                        columns: const [
                          DataColumn(label: Text('الاسم')),
                          DataColumn(label: Text('البريد الإلكتروني')),
                          DataColumn(label: Text('الرقم الوطني')),
                          DataColumn(label: Text('الدور')),
                          DataColumn(label: Text('إجراءات')),
                        ],
                        rows: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final role = data['role']?.toString() ?? 'citizen';
                          return DataRow(cells: [
                            DataCell(Text(data['fullName']?.toString() ?? '-')),
                            DataCell(Text(data['email']?.toString() ?? '-')),
                            DataCell(Text(data['nationalId']?.toString() ?? '-')),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: role == 'admin' ? Colors.red.shade100 : role == 'officer' ? Colors.blue.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(role == 'admin' ? 'مدير' : role == 'officer' ? 'ضابط' : 'مواطن',
                                style: TextStyle(color: role == 'admin' ? Colors.red : role == 'officer' ? Colors.blue : Colors.green, fontSize: 12)),
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(icon: const Icon(Icons.edit_note, size: 20, color: Colors.blue), tooltip: 'تغيير الدور',
                                  onPressed: () => _showRoleDialog(ctx, d.id, role),
                                ),
                                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), tooltip: 'حذف',
                                  onPressed: () => _confirmDelete(ctx, d.id, data['fullName'] ?? ''),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOfficerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة ضابط جديد', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email))),
                const SizedBox(height: 8),
                TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'الرقم الوطني', prefixIcon: Icon(Icons.badge))),
                const SizedBox(height: 8),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock)), obscureText: true),
                if (loading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: loading ? null : () async {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                
                setDialogState(() => loading = true);
                
                try {
                  // Initialize secondary app to avoid logging out admin
                  FirebaseApp tempApp = await Firebase.initializeApp(
                    name: 'TempApp',
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                  
                  UserCredential cred = await FirebaseAuth.instanceFor(app: tempApp)
                      .createUserWithEmailAndPassword(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                  );
                  
                  // Save to Firestore with 'officer' role
                  await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
                    'fullName': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'nationalId': idCtrl.text.trim(),
                    'role': 'officer',
                    'createdAt': FieldValue.serverTimestamp(),
                    'status': 'active',
                  });
                  
                  await tempApp.delete();
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة الضابط بنجاح'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  setDialogState(() => loading = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), foregroundColor: Colors.white),
              child: const Text('إضافة وحفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, String uid, String currentRole) {
    String selected = currentRole;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير دور المستخدم'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['citizen', 'officer', 'admin'].map((r) => RadioListTile<String>(
              value: r,
              groupValue: selected,
              title: Text(r == 'admin' ? 'مدير' : r == 'officer' ? 'ضابط' : 'مواطن'),
              onChanged: (v) => setState(() => selected = v!),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': selected});
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المستخدم "$name"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

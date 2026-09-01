import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViolationsScreen extends StatefulWidget {
  const ViolationsScreen({super.key});

  @override
  State<ViolationsScreen> createState() => _ViolationsScreenState();
}

class _ViolationsScreenState extends State<ViolationsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _userRole = 'citizen';

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  void _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() => _userRole = doc.data()?['role'] ?? 'citizen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Text('سجل المخالفات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث برقم اللوحة...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'paid', child: Text('مدفوعة')),
                  DropdownMenuItem(value: 'unpaid', child: Text('غير مدفوعة')),
                ],
                onChanged: (v) => setState(() => _statusFilter = v!),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('violations').orderBy('createdAt', descending: true).snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                
                var docs = snap.data!.docs;
                
                // Filtering
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) => (d.data() as Map)['licensePlate'].toString().contains(_searchQuery)).toList();
                }
                if (_statusFilter != 'all') {
                  docs = docs.where((d) => (d.data() as Map)['status'] == _statusFilter).toList();
                }

                if (docs.isEmpty) return const Center(child: Text('لا توجد نتائج مطابقة'));
                
                return Card(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F4F8)),
                        columns: const [
                          DataColumn(label: Text('نوع المخالفة')),
                          DataColumn(label: Text('رقم اللوحة')),
                          DataColumn(label: Text('المبلغ')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('إجراءات')),
                        ],
                        rows: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final status = data['status']?.toString() ?? '-';
                          return DataRow(cells: [
                            DataCell(Text(data['violationType']?.toString() ?? '-')),
                            DataCell(Text(data['licensePlate']?.toString() ?? '-')),
                            DataCell(Text('${data['fineAmount'] ?? 0} SDG')),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'paid' ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(status == 'paid' ? 'مدفوعة' : 'غير مدفوعة',
                                style: TextStyle(color: status == 'paid' ? Colors.green : Colors.orange, fontSize: 12)),
                            )),
                            DataCell(
                              _userRole == 'admin' 
                              ? IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  onPressed: () => _confirmDelete(context, d.id),
                                )
                              : const SizedBox.shrink()
                            ),
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المخالفة نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('violations').doc(id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

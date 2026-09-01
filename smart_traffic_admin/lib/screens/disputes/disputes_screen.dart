import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisputesScreen extends StatelessWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Row(children: [Text('إدارة الاعتراضات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)))]),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('disputes').orderBy('createdAt', descending: true).snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('لا توجد اعتراضات حالياً'));
                return Card(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F4F8)),
                        columns: const [
                          DataColumn(label: Text('سبب الاعتراض')),
                          DataColumn(label: Text('التاريخ')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('إجراءات')),
                        ],
                        rows: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final status = data['status']?.toString() ?? 'pending';
                          final timestamp = data['createdAt'] as Timestamp?;
                          final dateStr = timestamp != null ? '${timestamp.toDate().day}/${timestamp.toDate().month}' : '-';
                          
                          return DataRow(cells: [
                            DataCell(Text(data['reason']?.toString() ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(Text(dateStr)),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'approved' ? Colors.green.shade100 : status == 'rejected' ? Colors.red.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(status == 'approved' ? 'مقبول' : status == 'rejected' ? 'مرفوض' : 'قيد المراجعة',
                                style: TextStyle(color: status == 'approved' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange, fontSize: 12)),
                            )),
                            DataCell(Row(children: [
                              if (status == 'pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                                  tooltip: 'قبول الاعتراض',
                                  onPressed: () => _updateStatus(context, d.id, 'approved', 'هل تريد قبول هذا الاعتراض وإلغاء المخالفة؟'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 22),
                                  tooltip: 'رفض الاعتراض',
                                  onPressed: () => _updateStatus(context, d.id, 'rejected', 'هل تريد رفض هذا الاعتراض؟'),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue, size: 22),
                                tooltip: 'عرض التفاصيل',
                                onPressed: () => _showDetails(context, data),
                              ),
                            ])),
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

  void _updateStatus(BuildContext context, String docId, String newStatus, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus == 'approved' ? 'قبول الاعتراض' : 'رفض الاعتراض'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('disputes').doc(docId).update({'status': newStatus});
              Navigator.pop(ctx);
            },
            child: Text(newStatus == 'approved' ? 'تأكيد القبول' : 'تأكيد الرفض', style: TextStyle(color: newStatus == 'approved' ? Colors.green : Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تفاصيل الاعتراض'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السبب:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(data['reason'] ?? '-'),
            const SizedBox(height: 16),
            Text('رقم المخالفة المرتبطة:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(data['violationId'] ?? 'غير محدد'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}

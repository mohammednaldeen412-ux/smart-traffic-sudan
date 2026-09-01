import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehiclesSearchScreen extends StatefulWidget {
  const VehiclesSearchScreen({super.key});

  @override
  State<VehiclesSearchScreen> createState() => _VehiclesSearchScreenState();
}

class _VehiclesSearchScreenState extends State<VehiclesSearchScreen> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  Map<String, dynamic>? _vehicleData;
  List<QueryDocumentSnapshot> _violations = [];

  void _search() async {
    if (_searchCtrl.text.isEmpty) return;
    setState(() {
      _searching = true;
      _vehicleData = null;
      _violations = [];
    });

    try {
      final vDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('plateNumber', isEqualTo: _searchCtrl.text.trim())
          .limit(1)
          .get();

      if (vDoc.docs.isNotEmpty) {
        _vehicleData = vDoc.docs.first.data();
        
        final violDocs = await FirebaseFirestore.instance
            .collection('violations')
            .where('licensePlate', isEqualTo: _searchCtrl.text.trim())
            .orderBy('createdAt', descending: true)
            .get();
        
        _violations = violDocs.docs;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في البحث: $e')),
      );
    } finally {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('البحث عن المركبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'أدخل رقم اللوحة (مثلاً: 12345 خ)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _searching ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: _searching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('بحث'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_vehicleData != null) ...[
            _buildVehicleDetails(),
            const SizedBox(height: 24),
            _buildViolationHistory(),
          ] else if (!_searching && _searchCtrl.text.isNotEmpty)
            const Center(child: Text('لم يتم العثور على مركبة بهذا الرقم')),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.directions_car, color: Color(0xFF1E3A5F)),
                SizedBox(width: 8),
                Text('تفاصيل المركبة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _detailItem('المالك', _vehicleData!['ownerName'] ?? '-'),
                _detailItem('النوع', _vehicleData!['model'] ?? '-'),
                _detailItem('اللون', _vehicleData!['color'] ?? '-'),
                _detailItem('الحالة القانونية', _vehicleData!['status'] ?? 'سليمة'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildViolationHistory() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('سجل المخالفات لهذه المركبة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: _violations.isEmpty
                ? const Center(child: Text('لا توجد مخالفات مسجلة'))
                : ListView.builder(
                    itemCount: _violations.length,
                    itemBuilder: (context, index) {
                      final v = _violations[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(v['violationType'] ?? '-'),
                          subtitle: Text('المبلغ: ${v['fineAmount']} SDG - التاريخ: ${v['createdAt'] != null ? (v['createdAt'] as Timestamp).toDate().toString().split(' ')[0] : '-'}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: v['status'] == 'paid' ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              v['status'] == 'paid' ? 'مدفوعة' : 'معلقة',
                              style: TextStyle(color: v['status'] == 'paid' ? Colors.green : Colors.red, fontSize: 12),
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
}

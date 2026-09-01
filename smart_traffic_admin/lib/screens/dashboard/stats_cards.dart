import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نظرة عامة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(title: 'المستخدمون', icon: Icons.people, color: Colors.blue, collection: 'users'),
              _StatCard(title: 'المخالفات', icon: Icons.receipt_long, color: Colors.orange, collection: 'violations'),
              _StatCard(title: 'الاعتراضات', icon: Icons.gavel, color: Colors.red, collection: 'disputes'),
              _StatCard(title: 'المركبات', icon: Icons.directions_car, color: Colors.green, collection: 'vehicles'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('آخر المخالفات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('violations').orderBy('createdAt', descending: true).limit(10).snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('لا توجد مخالفات بعد'));
              return Card(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('المخالفة')),
                    DataColumn(label: Text('المبلغ')),
                    DataColumn(label: Text('الحالة')),
                  ],
                  rows: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['violationType']?.toString() ?? '-')),
                      DataCell(Text('${data['fineAmount'] ?? 0} SDG')),
                      DataCell(Text(data['status']?.toString() ?? '-')),
                    ]);
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String collection;
  const _StatCard({required this.title, required this.icon, required this.color, required this.collection});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  int? _count;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection(widget.collection).count().get().then((s) {
      if (mounted) setState(() => _count = s.count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, color: widget.color, size: 28),
          const Spacer(),
          Text(_count?.toString() ?? '...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: widget.color)),
          Text(widget.title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

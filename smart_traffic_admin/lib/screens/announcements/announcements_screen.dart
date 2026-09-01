import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});
  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    if (_titleCtrl.text.isEmpty || _bodyCtrl.text.isEmpty) return;
    setState(() => _sending = true);
    await FirebaseFirestore.instance.collection('announcements').add({
      'title': _titleCtrl.text.trim(),
      'body': _bodyCtrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _titleCtrl.clear();
    _bodyCtrl.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('إرسال تعميم جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                    const SizedBox(height: 16),
                    TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'عنوان التعميم', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _bodyCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'نص التعميم', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _send,
                        icon: const Icon(Icons.send),
                        label: _sending ? const Text('جاري الإرسال...') : const Text('إرسال التعميم'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // List
          Expanded(
            flex: 3,
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [Text('التعاميم السابقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('announcements').orderBy('createdAt', descending: true).snapshots(),
                      builder: (ctx, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snap.data!.docs;
                        if (docs.isEmpty) return const Center(child: Text('لا توجد تعاميم بعد'));
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final data = docs[i].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const Icon(Icons.campaign, color: Color(0xFF1E3A5F)),
                              title: Text(data['title']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(data['body']?.toString() ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => FirebaseFirestore.instance.collection('announcements').doc(docs[i].id).delete(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

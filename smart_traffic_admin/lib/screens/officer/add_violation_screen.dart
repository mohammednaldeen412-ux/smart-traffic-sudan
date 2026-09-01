import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddViolationScreen extends StatefulWidget {
  const AddViolationScreen({super.key});

  @override
  State<AddViolationScreen> createState() => _AddViolationScreenState();
}

class _AddViolationScreenState extends State<AddViolationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _selectedType = 'سرعة زائدة';
  bool _submitting = false;

  final List<String> _violationTypes = [
    'سرعة زائدة',
    'قطع إشارة',
    'وقوف خاطئ',
    'عكس مسار',
    'تظليل غير مسموح',
    'لوحات غير واضحة',
    'بدون رخصة قيادة',
    'أخرى',
  ];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final officerId = FirebaseAuth.instance.currentUser?.uid;
      
      await FirebaseFirestore.instance.collection('violations').add({
        'licensePlate': _plateCtrl.text.trim(),
        'violationType': _selectedType,
        'fineAmount': double.tryParse(_amountCtrl.text) ?? 0.0,
        'status': 'unpaid',
        'createdAt': FieldValue.serverTimestamp(),
        'officerId': officerId,
        'location': 'نقطة تفتيش', // Placeholder
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل المخالفة بنجاح'), backgroundColor: Colors.green),
        );
        _plateCtrl.clear();
        _amountCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التسجيل: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تسجيل مخالفة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _plateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'رقم لوحة المركبة',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                        hintText: 'مثال: 12345 خ',
                      ),
                      validator: (v) => v!.isEmpty ? 'يرجى إدخال رقم اللوحة' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع المخالفة',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _violationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ الغرامة (SDG)',
                        prefixIcon: Icon(Icons.money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'يرجى إدخال المبلغ' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: const Icon(Icons.save),
                        label: _submitting 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('تسجيل المخالفة الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

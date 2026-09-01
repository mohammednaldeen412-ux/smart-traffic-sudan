import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../users/users_screen.dart';
import '../violations/violations_screen.dart';
import '../disputes/disputes_screen.dart';
import '../announcements/announcements_screen.dart';
import 'stats_cards.dart';
import '../officer/vehicles_search_screen.dart';
import '../officer/add_violation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _userRole = 'citizen';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = doc.data()?['role'] ?? 'citizen';
        });
      }
    }
  }

  List<_NavItem> get _navItems {
    List<_NavItem> items = [
      _NavItem(icon: Icons.dashboard, label: 'الرئيسية'),
    ];

    if (_userRole == 'admin') {
      items.addAll([
        _NavItem(icon: Icons.people, label: 'المستخدمون'),
        _NavItem(icon: Icons.receipt_long, label: 'المخالفات'),
        _NavItem(icon: Icons.gavel, label: 'الاعتراضات'),
        _NavItem(icon: Icons.campaign, label: 'التعاميم'),
      ]);
    } else if (_userRole == 'officer') {
      items.addAll([
        _NavItem(icon: Icons.receipt_long, label: 'المخالفات'),
        _NavItem(icon: Icons.search, label: 'بحث المركبات'),
        _NavItem(icon: Icons.add_circle_outline, label: 'إضافة مخالفة'),
      ]);
    }

    return items;
  }

  Widget _getScreen() {
    final items = _navItems;
    if (_selectedIndex >= items.length) _selectedIndex = 0;
    
    final currentLabel = items[_selectedIndex].label;
    
    if (currentLabel == 'الرئيسية') return const StatsCards();
    if (currentLabel == 'المستخدمون') return const UsersScreen();
    if (currentLabel == 'المخالفات') return const ViolationsScreen();
    if (currentLabel == 'الاعتراضات') return const DisputesScreen();
    if (currentLabel == 'التعاميم') return const AnnouncementsScreen();
    if (currentLabel == 'بحث المركبات') return const VehiclesSearchScreen();
    if (currentLabel == 'إضافة مخالفة') return const AddViolationScreen();
    
    return const StatsCards();
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _navItems;
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (Restored to original style)
          Container(
            width: 220,
            color: const Color(0xFF1E3A5F),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.traffic, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text('Smart Traffic', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(_userRole == 'admin' ? 'لوحة الإدارة' : 'واجهة الضابط', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                Expanded(
                  child: ListView.builder(
                    itemCount: navItems.length,
                    itemBuilder: (ctx, i) {
                      final item = navItems[i];
                      final selected = _selectedIndex == i;
                      return ListTile(
                        leading: Icon(item.icon, color: selected ? Colors.white : Colors.white60),
                        title: Text(item.label, style: TextStyle(color: selected ? Colors.white : Colors.white60, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                        selected: selected,
                        selectedTileColor: Colors.white12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onTap: () => setState(() => _selectedIndex = i),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white60),
                  title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white60)),
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(navItems[_selectedIndex].label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                      const Spacer(),
                      const Icon(Icons.account_circle, size: 32, color: Color(0xFF1E3A5F)),
                      const SizedBox(width: 8),
                      StreamBuilder(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (ctx, snap) => Text(snap.data?.email ?? '', style: const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Screen content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                    child: _getScreen(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

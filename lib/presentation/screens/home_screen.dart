import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/home_qr_center.dart';
import '../widgets/home_sections_grid.dart';
import '../../data/repositories/auth_repository.dart';
import 'profile_screen.dart';
import 'support_screen.dart';
import 'language_selection_screen.dart';
import 'login_register_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _hotelId;
  final TextEditingController _codeController = TextEditingController(
    text: 'RmR001',
  );
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedHotelId();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedHotelId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_hotel_id');
    if (!mounted) return;
    setState(() => _hotelId = saved);
  }

  Future<void> _saveHotelId(String hotelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_hotel_id', hotelId);
    if (!mounted) return;
    setState(() => _hotelId = hotelId);
  }

  Future<void> _clearHotelId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_hotel_id');
    if (!mounted) return;
    setState(() => _hotelId = null);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository?>()?.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty == true)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? '');

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          displayName.isEmpty
              ? tr('welcome')
              : '${tr('welcome')}, $displayName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hotelId != null)
            IconButton(
              tooltip: tr('home.change_hotel'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await _clearHotelId();
                messenger.showSnackBar(
                  SnackBar(content: Text(tr('home.hotel_cleared'))),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
        ],
      ),
      drawer: _buildDrawer(context, displayName),

      body: Column(
        children: [
          Expanded(
            child: (_hotelId == null)
                ? HomeQrCenter(
                    message: tr('home.qr_prompt'),
                    controller: _codeController,
                    onConfirm: (String code) async {
                      final messenger = ScaffoldMessenger.of(context);
                      final trimmed = code.trim();
                      if (trimmed.isEmpty) return;
                      await _saveHotelId(trimmed);
                      messenger.showSnackBar(
                        SnackBar(content: Text(tr('home.hotel_linked'))),
                      );
                    },
                  )
                : HomeSectionsGrid(hotelId: _hotelId!),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(i == 1 ? tr('nav.orders') : tr('nav.profile')),
              ),
            );
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

Widget _drawerHeader(BuildContext context, String displayName) {
  final user = context.read<AuthRepository?>()?.currentUser;
  final name = displayName.isEmpty ? tr('welcome') : displayName;
  return UserAccountsDrawerHeader(
    decoration: const BoxDecoration(color: Colors.orange),
    accountName: Text(name, style: const TextStyle(color: Colors.white)),
    accountEmail: Text(user?.email ?? '', style: const TextStyle(color: Colors.white70)),
    currentAccountPicture: CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
          ? NetworkImage(user.photoURL!)
          : null,
      child: (user?.photoURL == null || user!.photoURL!.isEmpty)
          ? Text(
              (name.isNotEmpty ? name.characters.first : '?').toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
            )
          : null,
    ),
  );
}

Drawer _buildDrawer(BuildContext context, String displayName) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  final isAr = Localizations.localeOf(context).languageCode.startsWith('ar');
  final lProfile = isAr ? 'حسابي' : tr('drawer.profile');
  final lLang = isAr ? 'تغيير اللغة' : tr('drawer.change_language');
  final lLogout = isAr ? 'تسجيل الخروج' : tr('drawer.logout');
  final lSupport = isAr ? 'المساعدة والدعم' : tr('drawer.support');
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        _drawerHeader(context, displayName),
        ListTile(
          leading: Icon(Icons.person_outline, color: onSurface),
          title: Text(lProfile, style: TextStyle(color: onSurface)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
        ),
        ListTile(
          leading: Icon(Icons.language_outlined, color: onSurface),
          title: Text(lLang, style: TextStyle(color: onSurface)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(LanguageSelectionScreen.routeName);
          },
        ),
        ListTile(
          leading: Icon(Icons.support_agent_outlined, color: onSurface),
          title: Text(lSupport, style: TextStyle(color: onSurface)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(lLogout, style: const TextStyle(color: Colors.red)),
          onTap: () async {
            await context.read<AuthRepository?>()?.signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed(LoginRegisterScreen.routeName);
          },
        ),
      ],
    ),
  );
}

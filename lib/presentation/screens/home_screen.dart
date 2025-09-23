import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/home_qr_center.dart';
import '../widgets/home_sections_grid.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('home.title')),
        centerTitle: true,
        actions: [
          if (_hotelId != null)
            IconButton(
              tooltip: tr('home.change_hotel'),
              onPressed: () async {
                // التقط الماسنجر قبل الـ await لتفادي use_build_context_synchronously
                final messenger = ScaffoldMessenger.of(context);
                await _clearHotelId();
                // لا نستخدم context بعد await مباشرةً
                messenger.showSnackBar(
                  SnackBar(content: Text(tr('home.hotel_cleared'))),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
            ),
        ],
      ),

      // ملاحظة: لا تضع تعليقات وسط جملة الشرط الثلاثي (قبل أو بعد '?', ':')
      body: (_hotelId == null)
          // لا يوجد فندق محدد → عرض مركز إدخال/مسح الكود
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
          // يوجد فندق محدد → عرض الشبكة
          : HomeSectionsGrid(hotelId: _hotelId!),
    );
  }
}

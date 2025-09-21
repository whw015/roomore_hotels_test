import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AuthRepository>().currentUser;
    final displayName = _displayName(user?.displayName, user?.email);
    final email = user?.email ?? 'لم يتم تحديد البريد الإلكتروني';
    final phone = user?.phoneNumber ?? 'لم يتم إضافة رقم الجوال';
    final photoUrl = user?.photoURL;
    final initials = displayName.isEmpty
        ? '?'
        : String.fromCharCode(displayName.runes.first).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage:
                  photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Text(
                      initials,
                      style: theme.textTheme.headlineMedium,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('البريد الإلكتروني'),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('رقم الجوال'),
              subtitle: Text(phone),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('آخر تسجيل دخول'),
              subtitle: Text(_lastSignIn(user?.metadata.lastSignInTime)),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تعديل الملف الشخصي قيد التطوير')),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('تعديل البيانات'),
          ),
        ],
      ),
    );
  }

  static String _displayName(String? displayName, String? email) {
    final trimmed = displayName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'ضيف';
  }

  static String _lastSignIn(DateTime? lastSignIn) {
    if (lastSignIn == null) {
      return 'غير متوفر';
    }
    return '${lastSignIn.day}/${lastSignIn.month}/${lastSignIn.year}';
  }
}

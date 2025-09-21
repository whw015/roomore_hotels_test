import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة و الدعم'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('الدردشة المباشرة'),
              subtitle: const Text('تواصل مع فريق الدعم على مدار الساعة'),
              onTap: () => _showMessage(context, 'سيتم فتح الدردشة قريباً'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('البريد الإلكتروني'),
              subtitle: const Text('support@roomore.app'),
              onTap: () => _showMessage(context, 'تم نسخ البريد الإلكتروني'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.call_outlined),
              title: const Text('اتصال هاتفي'),
              subtitle: const Text('+966 500 000 000'),
              onTap: () => _showMessage(context, 'سيتم الاتصال بخدمة العملاء قريباً'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'نحن هنا لمساعدتك',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'يمكنك التواصل معنا في أي وقت للاستفسارات أو الملاحظات، وسيقوم فريق الدعم بالرد عليك في أقرب فرصة.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

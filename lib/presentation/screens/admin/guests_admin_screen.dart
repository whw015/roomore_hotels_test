import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GuestsAdminScreen extends StatelessWidget {
  static const routeName = '/admin/guests';
  const GuestsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('admin.guests.title'))),
      body: Center(child: Text(tr('todo.soon'))),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WorkgroupsAdminScreen extends StatelessWidget {
  static const routeName = '/admin/workgroups';
  const WorkgroupsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('admin.workgroups.title'))),
      body: Center(child: Text(tr('todo.soon'))),
    );
  }
}

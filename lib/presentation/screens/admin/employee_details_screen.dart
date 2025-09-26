import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomore_hotels_test/utils/countries.dart';
import 'package:roomore_hotels_test/utils/ui.dart';

import '../../../data/models/employee.dart';
import '../../../data/repositories/employee_repository.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  static const routeName = '/admin/employees/details';
  final Employee employee;

  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _title;
  late final TextEditingController _employeeNo;
  late final TextEditingController _idNumber;
  String _gender = 'male';
  String _nationality = 'SA';
  DateTime? _birthDate;
  bool _isActive = true;
  String _workgroup = 'staff';
  String? _avatarUrl;
  final _picker = ImagePicker();
  bool _saving = false;

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime(now.year - 10, now.month, now.day),
    );
    if (!mounted) return;
    setState(() => _birthDate = res);
  }

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _fullName = TextEditingController(text: e.fullName);
    _email = TextEditingController(text: e.email);
    _phone = TextEditingController(text: e.phone);
    _title = TextEditingController(text: e.title ?? '');
    _employeeNo = TextEditingController(text: e.employeeNo ?? '');
    _idNumber = TextEditingController(text: e.idNumber ?? '');
    _gender = e.gender.isNotEmpty ? e.gender : 'male';
    _nationality = e.nationality.isNotEmpty ? e.nationality : 'SA';
    _birthDate = e.birthDate;
    _isActive = e.isActive;
    _workgroup = e.workgroup;
    _avatarUrl = e.avatarUrl;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _title.dispose();
    _employeeNo.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted || img == null) return;
    final repo = EmployeeRepository();
    try {
      final url = await repo.uploadAvatar(File(img.path));
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('common.refreshed'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('errors.network_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.employee;
    final repo = EmployeeRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('admin.employees.title')),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            tooltip: tr('actions.save'),
            onPressed: () async {
              if (_saving || !_formKey.currentState!.validate()) return;
              try {
                setState(() => _saving = true);
                final updated = await repo.updateEmployee(
                  id: e.id,
                  hotelId: e.hotelId,
                  fullName: _fullName.text.trim(),
                  email: _email.text.trim(),
                  phone: _phone.text.trim(),
                  gender: _gender,
                  nationality: _nationality,
                  birthDate: _birthDate,
                  idNumber: _idNumber.text.trim().isEmpty ? null : _idNumber.text.trim(),
                  avatarUrl: _avatarUrl,
                  title: _title.text.trim().isEmpty ? null : _title.text.trim(),
                  employeeNo: _employeeNo.text.trim().isEmpty ? null : _employeeNo.text.trim(),
                  workgroup: _workgroup,
                  isActive: _isActive,
                );
                if (!context.mounted) return;
                showSuccessSnack(context, tr('common.refreshed'));
                Navigator.of(context).pop({'updated': updated});
              } catch (err) {
                if (!context.mounted) return;
                showErrorSnack(context, err.toString());
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(tr('admin.employees.title')),
                  content: Text(tr('confirm')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
                    )
                  ],
                ),
              );
              if (yes == true) {
                try {
                  await repo.deleteEmployee(id: e.id);
                  if (!context.mounted) return;
                  Navigator.of(context).pop({'deleted': true});
                } catch (err) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _pickAndUpload,
                    icon: const Icon(Icons.photo),
                    label: Text(tr('admin.employees.fields.avatar_url')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullName,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.full_name'),
                  prefixIcon: const Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.email'),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.phone'),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _gender,
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text(
                      tr('admin.employees.fields.gender_m'),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text(
                      tr('admin.employees.fields.gender_f'),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
                onChanged: (v) => _gender = v ?? 'male',
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.gender'),
                  prefixIcon: const Icon(Icons.wc),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _nationality,
                items: kCountries
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.code,
                        child: Text(
                          '${c.code} - ${context.locale.languageCode == 'ar' ? c.nameAr : c.nameEn}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => _nationality = v ?? 'SA',
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.nationality'),
                  prefixIcon: const Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickBirthdate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('admin.employees.fields.birthdate'),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                  child: Text(
                    _birthDate == null
                        ? tr('admin.employees.fields.birthdate_pick')
                        : DateFormat.yMMMd(context.locale.toLanguageTag()).format(_birthDate!),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.job_title'),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _employeeNo,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.employee_no'),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _idNumber,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.id_number'),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(tr('admin.employees.fields.is_active')),
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _workgroup,
                onChanged: (v) => _workgroup = v,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.workgroup'),
                  prefixIcon: const Icon(Icons.groups_2_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

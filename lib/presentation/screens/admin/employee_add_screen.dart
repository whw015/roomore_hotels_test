import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomore_hotels_test/cubits/employee_form/employee_form_cubit.dart';
import 'package:roomore_hotels_test/data/repositories/employee_repository.dart';
import 'package:roomore_hotels_test/utils/countries.dart';

class EmployeeAddScreen extends StatefulWidget {
  static const String employeesAdd = '/admin/employees/add';
  final String hotelId;
  const EmployeeAddScreen({super.key, required this.hotelId});
  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _title = TextEditingController();
  final _employeeNo = TextEditingController();
  final _idNumber = TextEditingController();
  String _gender = 'male';
  String _nationality = 'SA';
  DateTime? _birthDate;
  bool _isActive = true;
  String _workgroup = 'staff';
  XFile? _pickedImage;
  final _imagePicker = ImagePicker();

  String? _uploadedAvatarUrl;
  @override
  void initState() {
    super.initState();
    _seedDefaultsForTesting();
  }

  void _seedDefaultsForTesting() {
    // Seed simple, readable defaults to speed up manual testing
    final ts = DateTime.now().millisecondsSinceEpoch % 1000000;
    _fullName.text = 'Test Employee $ts';
    _email.text = 'test$ts@roomore.dev';
    _phone.text = '055${(ts % 9000000) + 1000000}';
    _title.text = 'Staff';
    _employeeNo.text = 'E$ts';
    _idNumber.text = 'ID$ts';
    _gender = 'male';
    _nationality = 'SA';
    _birthDate = DateTime(1994, 1, 1);
    _isActive = true;
    _workgroup = 'staff';
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

  Future<void> _pickImage() async {
    final img = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _pickedImage = img);
    if (img != null) {
      final repo = EmployeeRepository();
      try {
        final url = await repo.uploadAvatar(File(img.path));
        if (!mounted) return;
        setState(() => _uploadedAvatarUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('common.refreshed'))));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('errors.network_error'))));
  }
    }
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime(now.year - 10, now.month, now.day),
    );
    if (!mounted) return;
    setState(() => _birthDate = res);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unrelated_type_equality_checks
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    final hotelId = widget.hotelId;
    return BlocProvider(
      create: (_) => EmployeeFormCubit(EmployeeRepository()),
      child: BlocConsumer<EmployeeFormCubit, EmployeeFormState>(
        listener: (context, state) async {
          if (state.success) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr('admin.employees.add.success'))),
            );
            Navigator.of(context).pop(true);
          } else if (state.error != null) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final repo = EmployeeRepository();
          return Scaffold(
            appBar: AppBar(
              title: Text(tr('admin.employees.add.title')),
              actions: [
                IconButton(
                  tooltip: tr('admin.employees.add.add'),
                  onPressed: state.submitting
                      ? null
                      : () => _onSubmit(context, hotelId, repo),
                  icon: const Icon(Icons.check),
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
                          backgroundImage: _pickedImage != null
                              ? FileImage(File(_pickedImage!.path))
                              : null,
                          child: _pickedImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: state.submitting ? null : _pickImage,
                          icon: const Icon(Icons.photo),
                          label: Text(tr('admin.employees.fields.avatar_url')),
                        ),
                      ],
                    ),
                    if (_uploadedAvatarUrl != null) ...[
                      const SizedBox(height: 8),
                      SelectableText(_uploadedAvatarUrl!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
                      ),
                    ],
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _fullName,
                      decoration: InputDecoration(
                        labelText: tr('admin.employees.fields.full_name'),
                        prefixIcon: const Icon(Icons.badge),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? tr('validation.required')
                          : null,
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
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text(
                            tr('admin.employees.fields.gender_f'),
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                      onChanged: state.submitting
                          ? null
                          : (v) => setState(() => _gender = v ?? 'male'),
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
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: state.submitting
                          ? null
                          : (v) => setState(() => _nationality = v ?? 'SA'),
                      decoration: InputDecoration(
                        labelText: tr('admin.employees.fields.nationality'),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: state.submitting ? null : _pickBirthdate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: tr('admin.employees.fields.birthdate'),
                          prefixIcon: const Icon(Icons.cake),
                        ),
                        child: Text(
                          _birthDate == null
                              ? tr('admin.employees.fields.birthdate_pick')
                              : DateFormat.yMMMd(
                                  context.locale.toLanguageTag(),
                                ).format(_birthDate!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                      onChanged: state.submitting
                          ? null
                          : (v) => setState(() => _isActive = v),
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
                    const SizedBox(height: 24),

                    FilledButton.icon(
                      onPressed: state.submitting
                          ? null
                          : () => _onSubmit(context, hotelId, repo),
                      icon: state.submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(tr('admin.employees.add.add')),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: isRTL
                ? FloatingActionButtonLocation.startFloat
                : FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  Future<void> _onSubmit(
    BuildContext context,
    String hotelId,
    EmployeeRepository repo,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    String? avatarUrl;
    if (_pickedImage != null) {
      try {
        avatarUrl = await repo.uploadAvatar(File(_pickedImage!.path));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr('errors.network_error'))));
      }
    }
    if (!context.mounted) return;
    context.read<EmployeeFormCubit>().submit(
      hotelId: hotelId,
      fullName: _fullName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      gender: _gender,
      nationality: _nationality,
      birthDate: _birthDate,
      idNumber: _idNumber.text.trim().isEmpty ? null : _idNumber.text.trim(),
      avatarUrl: avatarUrl,
      title: _title.text.trim().isEmpty ? null : _title.text.trim(),
      employeeNo: _employeeNo.text.trim().isEmpty
          ? null
          : _employeeNo.text.trim(),
      workgroup: _workgroup,
      isActive: _isActive,
    );
  }
}

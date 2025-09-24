import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:roomore_hotels_test/cubits/employee_form/employee_form_cubit.dart';
import 'package:roomore_hotels_test/data/repositories/employee_repository.dart';

class EmployeeAddScreen extends StatefulWidget {
  static const routeName = '/admin/employees/add';
  final String? hotelId; // يمكن تمريره عبر الكونستركتور أو عبر arguments

  const EmployeeAddScreen({super.key, this.hotelId});

  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _empNoController = TextEditingController();

  // Fields
  String _gender = 'male';
  String _countryCode = 'SA';
  DateTime? _pickedBirthDate;
  String? _uploadedAvatarUrl;
  String _selectedWorkgroup = 'staff';
  bool _isActive = true;

  File? _pickedImageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _titleController.dispose();
    _empNoController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 25, now.month, now.day);
    final first = DateTime(now.year - 80);
    final last = DateTime(now.year - 15);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (!mounted) return;
    setState(() => _pickedBirthDate = date);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x == null) return;
    setState(() {
      _pickedImageFile = File(x.path);
    });
  }

  // placeholder رفع الصورة — اربطه لاحقاً بـ API فعلي:
  Future<String?> _uploadImageIfAny() async {
    if (_pickedImageFile == null) return _uploadedAvatarUrl;
    // TODO: ارفع الملف فعليًا وأرجع الرابط
    // مؤقتًا نعيد مسار تقريبي:
    final fileName = 'emp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return 'https://brq25.com/roomore-api/api/uploads/$fileName';
  }

  List<DropdownMenuItem<String>> _isoCountries() {
    const codes = [
      'SA',
      'AE',
      'EG',
      'JO',
      'KW',
      'BH',
      'QA',
      'OM',
      'YE',
      'SD',
      'DZ',
      'MA',
      'TN',
      'TR',
      'IN',
      'PK',
      'PH',
      'BD',
      'ID',
      'US',
      'GB',
      'FR',
      'DE',
      'ES',
      'IT',
    ];
    return codes
        .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // hotelId من args أو من الخاصية
    final args = ModalRoute.of(context)?.settings.arguments;
    final argHotelId = (args is Map && args['hotelId'] is String)
        ? args['hotelId'] as String
        : null;
    final hotelId = widget.hotelId ?? argHotelId ?? 'UNKNOWN';

    return BlocProvider(
      create: (_) => EmployeeFormCubit(EmployeeRepository()),
      child: BlocListener<EmployeeFormCubit, EmployeeFormState>(
        listenWhen: (p, c) =>
            p.success != c.success ||
            p.error != c.error ||
            p.submitting != c.submitting,
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إنشاء الموظف بنجاح')),
            );
            Navigator.of(context).pop(true);
          } else if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('إضافة موظف')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // صورة + معاينة
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!)
                            : (_uploadedAvatarUrl != null
                                  ? NetworkImage(_uploadedAvatarUrl!)
                                        as ImageProvider
                                  : null),
                        child:
                            (_pickedImageFile == null &&
                                _uploadedAvatarUrl == null)
                            ? const Icon(Icons.person, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo),
                        label: const Text('اختر صورة'),
                      ),
                      if (_uploadedAvatarUrl != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _uploadedAvatarUrl!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'الإيميل'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'الإيميل مطلوب'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'رقم الجوال'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'رقم الجوال مطلوب'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // الجنس
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'الجنس'),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('ذكر')),
                      DropdownMenuItem(value: 'female', child: Text('أنثى')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? 'male'),
                  ),
                  const SizedBox(height: 12),

                  // الجنسية ISO
                  DropdownButtonFormField<String>(
                    initialValue: _countryCode,
                    decoration: const InputDecoration(
                      labelText: 'الجنسية (ISO)',
                    ),
                    items: _isoCountries(),
                    onChanged: (v) => setState(() => _countryCode = v ?? 'SA'),
                  ),
                  const SizedBox(height: 12),

                  // تاريخ الميلاد
                  InkWell(
                    onTap: _pickBirthDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الميلاد',
                      ),
                      child: Text(
                        _pickedBirthDate == null
                            ? 'غير محدد'
                            : '${_pickedBirthDate!.year}-${_pickedBirthDate!.month.toString().padLeft(2, '0')}-${_pickedBirthDate!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _idNumberController,
                    decoration: const InputDecoration(labelText: 'رقم الهوية'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'المسمى الوظيفي',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _empNoController,
                    decoration: const InputDecoration(
                      labelText: 'الرقم الوظيفي',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  // مجموعة العمل
                  DropdownButtonFormField<String>(
                    initialValue: _selectedWorkgroup,
                    decoration: const InputDecoration(
                      labelText: 'مجموعة العمل',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'staff', child: Text('Staff')),
                      DropdownMenuItem(
                        value: 'housekeeping',
                        child: Text('Housekeeping'),
                      ),
                      DropdownMenuItem(
                        value: 'reception',
                        child: Text('Reception'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedWorkgroup = v ?? 'staff'),
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    value: _isActive,
                    title: const Text('نشِط'),
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<EmployeeFormCubit, EmployeeFormState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: state.submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            state.submitting ? 'جارٍ الحفظ...' : 'حفظ',
                          ),
                          onPressed: state.submitting
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  // نحصل على الكيوبت قبل أي await لتفادي use_build_context_synchronously
                                  final formCubit = context
                                      .read<EmployeeFormCubit>();

                                  final url = await _uploadImageIfAny();
                                  if (!mounted) return;
                                  setState(() => _uploadedAvatarUrl = url);

                                  await formCubit.submit(
                                    hotelId: hotelId,
                                    fullName: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    gender: _gender,
                                    nationality: _countryCode,
                                    birthDate: _pickedBirthDate,
                                    idNumber:
                                        _idNumberController.text.trim().isEmpty
                                        ? null
                                        : _idNumberController.text.trim(),
                                    avatarUrl: _uploadedAvatarUrl,
                                    title: _titleController.text.trim().isEmpty
                                        ? null
                                        : _titleController.text.trim(),
                                    employeeNo:
                                        _empNoController.text.trim().isEmpty
                                        ? null
                                        : _empNoController.text.trim(),
                                    workgroup: _selectedWorkgroup,
                                    isActive: _isActive,
                                  );
                                },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:roomore_hotels_test/data/models/guest.dart';
import 'package:roomore_hotels_test/data/repositories/guest_repository.dart';
import 'package:roomore_hotels_test/utils/countries.dart';
import 'package:roomore_hotels_test/utils/ui.dart';

class GuestDetailsScreen extends StatefulWidget {
  final Guest guest;
  final String hotelId;
  const GuestDetailsScreen({super.key, required this.guest, required this.hotelId});

  @override
  State<GuestDetailsScreen> createState() => _GuestDetailsScreenState();
}

class _GuestDetailsScreenState extends State<GuestDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _idNumber;
  late final TextEditingController _jobTitle;
  late final TextEditingController _employeeId;
  String _gender = 'male';
  String _nationality = 'SA';
  DateTime? _birthDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.guest;
    _name = TextEditingController(text: g.fullName);
    _email = TextEditingController(text: g.email);
    _phone = TextEditingController(text: g.phone);
    _idNumber = TextEditingController(text: g.idNumber ?? '');
    _jobTitle = TextEditingController(text: g.jobTitle ?? '');
    _employeeId = TextEditingController(text: g.employeeId ?? '');
    _gender = g.gender.isNotEmpty ? g.gender : 'male';
    _nationality = g.nationality.isNotEmpty ? g.nationality : 'SA';
    _birthDate = g.birthDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _idNumber.dispose();
    _jobTitle.dispose();
    _employeeId.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final repo = GuestRepository();
    final g = widget.guest;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('admin.guests.title')),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            tooltip: tr('actions.save'),
            onPressed: () async {
              if (_saving || !_formKey.currentState!.validate()) return;
              try {
                setState(() => _saving = true);
                final updated = await repo.updateGuest(
                  id: g.id,
                  hotelId: widget.hotelId,
                  fullName: _name.text.trim(),
                  email: _email.text.trim(),
                  phone: _phone.text.trim(),
                  gender: _gender,
                  nationality: _nationality,
                  birthDate: _birthDate,
                  idNumber: _idNumber.text.trim().isEmpty ? null : _idNumber.text.trim(),
                  jobTitle: _jobTitle.text.trim().isEmpty ? null : _jobTitle.text.trim(),
                  employeeId: _employeeId.text.trim().isEmpty ? null : _employeeId.text.trim(),
                );
                if (!context.mounted) return;
                showSuccessSnack(context, tr('common.refreshed'));
                Navigator.of(context).pop({'updated': updated});
              } catch (e) {
                if (!context.mounted) return;
                showErrorSnack(context, e.toString());
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(tr('admin.guests.title')),
                  content: Text(tr('confirm')),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(MaterialLocalizations.of(ctx).okButtonLabel)),
                  ],
                ),
              );
              if (yes == true) {
                try {
                  await repo.deleteGuest(id: g.id);
                  if (!context.mounted) return;
                  Navigator.of(context).pop({'deleted': true});
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorSnack(context, e.toString());
                }
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: tr('admin.employees.fields.full_name'), prefixIcon: const Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: tr('admin.employees.fields.email'), prefixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(labelText: tr('admin.employees.fields.phone'), prefixIcon: const Icon(Icons.phone_outlined)),
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
                decoration: InputDecoration(labelText: tr('admin.employees.fields.gender'), prefixIcon: const Icon(Icons.wc)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _nationality,
                items: kCountries
                    .map((c) => DropdownMenuItem(
                          value: c.code,
                          child: Text(
                            '${c.code} - ${context.locale.languageCode == 'ar' ? c.nameAr : c.nameEn}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => _nationality = v ?? 'SA',
                decoration: InputDecoration(labelText: tr('admin.employees.fields.nationality'), prefixIcon: const Icon(Icons.flag_outlined)),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickBirthdate,
                child: InputDecorator(
                  decoration: InputDecoration(labelText: tr('admin.employees.fields.birthdate'), prefixIcon: const Icon(Icons.cake_outlined)),
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
                controller: _jobTitle,
                decoration: InputDecoration(labelText: tr('admin.employees.fields.job_title'), prefixIcon: const Icon(Icons.work_outline)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _employeeId,
                decoration: InputDecoration(labelText: tr('admin.employees.fields.employee_no'), prefixIcon: const Icon(Icons.badge_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idNumber,
                decoration: InputDecoration(labelText: tr('admin.employees.fields.id_number'), prefixIcon: const Icon(Icons.credit_card)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

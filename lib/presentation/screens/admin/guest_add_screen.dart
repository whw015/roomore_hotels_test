import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:roomore_hotels_test/data/models/guest.dart';
import 'package:roomore_hotels_test/data/repositories/guest_repository.dart';
import 'package:roomore_hotels_test/utils/ui.dart';

class GuestAddScreen extends StatefulWidget {
  final String hotelId;
  const GuestAddScreen({super.key, required this.hotelId});

  @override
  State<GuestAddScreen> createState() => _GuestAddScreenState();
}

class _GuestAddScreenState extends State<GuestAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _room = TextEditingController();
  Guest? _selected;
  bool? _active; // null=unknown
  bool _loading = false;
  late final GuestRepository _repo;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _room.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _repo = GuestRepository();
    _seedDefaultsForTesting();
  }

  void _seedDefaultsForTesting() {
    final ts = DateTime.now().millisecondsSinceEpoch % 1000000;
    _email.text = 'guest$ts@roomore.dev';
    _phone.text = '055${(ts % 9000000) + 1000000}';
    _room.text = '${100 + (ts % 400)}';
  }

  // No birthdate picker needed in the new flow (view-only)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('admin.guests.title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.email'),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(
                  labelText: tr('admin.employees.fields.phone'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() => _loading = true);
                              try {
                                final list = await _repo.fetchAll(hotelId: widget.hotelId);
                                final email = _email.text.trim().toLowerCase();
                                final phone = _phone.text.trim();
                                final g = list.firstWhere(
                                  (x) => (email.isNotEmpty && x.email.toLowerCase() == email) ||
                                          (phone.isNotEmpty && x.phone == phone),
                                  orElse: () => list.isNotEmpty ? list.first : throw Exception('Guest not found'),
                                );
                                _selected = g;
                                // Try to fetch active status if backend supports it
                                _active = await _repo.isGuestActive(guestId: g.id, hotelId: widget.hotelId);
                                if (!context.mounted) return;
                                setState(() {});
                              } catch (e) {
                                if (!context.mounted) return;
                                showErrorSnack(context, e.toString());
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      label: Text(tr('home.search_tap')),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_selected != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_selected!.fullName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(_selected!.email),
                        Text(_selected!.phone),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _room,
                decoration: InputDecoration(
                  labelText: tr('room_number'),
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
                ),
              ),
              const SizedBox(height: 16),

              if (_selected != null)
                FilledButton(
                  style: (_active ?? false)
                      ? FilledButton.styleFrom(backgroundColor: Colors.red)
                      : null,
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_selected == null) return;
                          setState(() => _loading = true);
                          try {
                            if (_active == true) {
                              await _repo.checkOutGuest(hotelId: widget.hotelId, guestId: _selected!.id);
                              _active = false;
                              if (!context.mounted) return;
                              showSuccessSnack(context, tr('home.actions.checkout'));
                            } else {
                              await _repo.checkInGuest(hotelId: widget.hotelId, guestId: _selected!.id, roomNumber: _room.text.trim());
                              _active = true;
                              if (!context.mounted) return;
                              showSuccessSnack(context, tr('home.actions.checkout_in_progress'));
                            }
                            if (mounted) setState(() {});
                          } catch (e) {
                            if (!context.mounted) return;
                            showErrorSnack(context, e.toString());
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  child: Text((_active ?? false) ? tr('home.actions.checkout') : tr('common.confirm')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/presentation/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/services_admin/services_admin_cubit.dart';
import '../../cubits/services_admin/services_admin_state.dart';
import '../../data/models/item.dart';
import '../../data/models/localized_text.dart';
import '../../data/models/section.dart';
import '../../data/repositories/admin_services_repository.dart';
import '../../data/repositories/firestore_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ربط الفندق
  final TextEditingController _codeCtrl = TextEditingController();
  bool _resolving = false;

  // إضافة قسم جذري
  final _rootNameAr = TextEditingController();
  final _rootNameEn = TextEditingController();
  final _rootOrderCtrl = TextEditingController(text: '0');
  bool _rootActive = true;

  // إضافة قسم فرعي
  final _subNameAr = TextEditingController();
  final _subNameEn = TextEditingController();
  final _subOrderCtrl = TextEditingController(text: '0');
  bool _subActive = true;

  // إضافة عنصر
  final _itemNameAr = TextEditingController();
  final _itemNameEn = TextEditingController();
  final _itemDescAr = TextEditingController();
  final _itemDescEn = TextEditingController();
  final _itemPriceCtrl = TextEditingController(text: '0');
  final _itemCurrencyCtrl = TextEditingController(text: 'SAR');
  bool _itemAvailable = true;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _rootNameAr.dispose();
    _rootNameEn.dispose();
    _rootOrderCtrl.dispose();
    _subNameAr.dispose();
    _subNameEn.dispose();
    _subOrderCtrl.dispose();
    _itemNameAr.dispose();
    _itemNameEn.dispose();
    _itemDescAr.dispose();
    _itemDescEn.dispose();
    _itemPriceCtrl.dispose();
    _itemCurrencyCtrl.dispose();
    super.dispose();
  }

  // يربط الفندق عبر كود: يجرب docId ثم where('code'==code)
  Future<void> _resolveHotelByCode(BuildContext ctx) async {
    setState(() => _resolving = true);
    try {
      final code = _codeCtrl.text.trim();
      if (code.isEmpty) {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(tr('errors.required'))));
        return;
      }

      final repo = FirestoreRepository(firestore: FirebaseFirestore.instance);
      final resolvedId = await repo.resolveHotelIdByCode(code);

      if (!ctx.mounted) return;

      if (resolvedId == null) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(tr('errors.not_found'))));
        return;
      }

      // لا تنتظرها إن كانت ترجع void
      ctx.read<ServicesAdminCubit>().setHotelId(resolvedId);

      if (!ctx.mounted) return;
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(tr('hotel.home.hotelLinked'))));
    } catch (e) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _showAddRootSectionDialog(BuildContext ctx) async {
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: ctx,
      builder: (dCtx) {
        return AlertDialog(
          title: Text(tr('hotel.home.addRootSection')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _rootNameAr,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.nameAr'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('errors.required')
                        : null,
                  ),
                  TextFormField(
                    controller: _rootNameEn,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.nameEn'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('errors.required')
                        : null,
                  ),
                  TextFormField(
                    controller: _rootOrderCtrl,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.order'),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    value: _rootActive,
                    onChanged: (v) => setState(() => _rootActive = v),
                    title: Text(tr('hotel.forms.isActive')),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: Text(tr('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final order = int.tryParse(_rootOrderCtrl.text) ?? 0;

                ctx.read<ServicesAdminCubit>().addRootSection(
                  nameAr: _rootNameAr.text.trim(),
                  nameEn: _rootNameEn.text.trim(),
                  order: order,
                  isActive: _rootActive,
                );

                if (!dCtx.mounted) return;
                Navigator.of(dCtx).pop();

                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(tr('hotel.home.sectionAdded'))),
                );

                _rootNameAr.clear();
                _rootNameEn.clear();
                _rootOrderCtrl.text = '0';
                setState(() => _rootActive = true);
              },
              child: Text(tr('common.save')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddSubSectionDialog(
    BuildContext ctx,
    Section parent,
  ) async {
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: ctx,
      builder: (dCtx) {
        return AlertDialog(
          title: Text(tr('hotel.home.addSubSection')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _subNameAr,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.nameAr'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('errors.required')
                        : null,
                  ),
                  TextFormField(
                    controller: _subNameEn,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.nameEn'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('errors.required')
                        : null,
                  ),
                  TextFormField(
                    controller: _subOrderCtrl,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.order'),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    value: _subActive,
                    onChanged: (v) => setState(() => _subActive = v),
                    title: Text(tr('hotel.forms.isActive')),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: Text(tr('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final order = int.tryParse(_subOrderCtrl.text) ?? 0;

                ctx.read<ServicesAdminCubit>().addSubSection(
                  parentSectionId: parent.id,
                  nameAr: _subNameAr.text.trim(),
                  nameEn: _subNameEn.text.trim(),
                  order: order,
                  isActive: _subActive,
                );

                if (!dCtx.mounted) return;
                Navigator.of(dCtx).pop();

                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(tr('hotel.home.subSectionAdded'))),
                );

                _subNameAr.clear();
                _subNameEn.clear();
                _subOrderCtrl.text = '0';
                setState(() => _subActive = true);
              },
              child: Text(tr('common.save')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddItemSheet(
    BuildContext ctx, {
    required String parentSectionId,
    required String sectionId,
  }) async {
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr('hotel.home.addItem'),
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _itemNameAr,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.nameAr'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('errors.required')
                        : null,
                  ),
                  TextFormField(
                    controller: _itemNameEn,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.nameEn'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr('errors.required')
                        : null,
                  ),
                  TextFormField(
                    controller: _itemDescAr,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.descAr'),
                    ),
                  ),
                  TextFormField(
                    controller: _itemDescEn,
                    decoration: InputDecoration(
                      labelText: tr('hotel.forms.descEn'),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _itemPriceCtrl,
                          decoration: InputDecoration(
                            labelText: tr('hotel.forms.price'),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final d = double.tryParse(v ?? '');
                            return d == null ? tr('errors.number') : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _itemCurrencyCtrl,
                          decoration: InputDecoration(
                            labelText: tr('hotel.forms.currency'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    value: _itemAvailable,
                    onChanged: (v) => setState(() => _itemAvailable = v),
                    title: Text(tr('hotel.forms.isAvailable')),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        child: Text(tr('common.cancel')),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final price = double.parse(_itemPriceCtrl.text);
                          final currency = _itemCurrencyCtrl.text.trim().isEmpty
                              ? 'SAR'
                              : _itemCurrencyCtrl.text.trim();

                          final item = Item(
                            id: '',
                            name: LocalizedText(
                              ar: _itemNameAr.text.trim(),
                              en: _itemNameEn.text.trim(),
                            ),
                            description: LocalizedText(
                              ar: _itemDescAr.text.trim().isEmpty
                                  ? null
                                  : _itemDescAr.text.trim(),
                              en: _itemDescEn.text.trim().isEmpty
                                  ? null
                                  : _itemDescEn.text.trim(),
                            ),
                            imageUrls: const [],
                            price: price,
                            currency: currency,
                            isAvailable: _itemAvailable,
                            options: const [],
                          );

                          await ctx.read<ServicesAdminCubit>().addItem(
                            // نمرر الاثنين (يمكنك تخزين parent داخل العنصر إن رغبت)
                            sectionId: sectionId,
                            item: item,
                            parentSectionId: parentSectionId,
                          );

                          if (!sheetCtx.mounted) return;
                          Navigator.of(sheetCtx).pop();

                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(tr('hotel.home.itemAdded'))),
                          );

                          _itemNameAr.clear();
                          _itemNameEn.clear();
                          _itemDescAr.clear();
                          _itemDescEn.clear();
                          _itemPriceCtrl.text = '0';
                          _itemCurrencyCtrl.text = 'SAR';
                          setState(() => _itemAvailable = true);
                        },
                        child: Text(tr('common.save')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesAdminCubit, ServicesAdminState>(
      builder: (context, state) {
        final hotelId = state.hotelId;

        return Scaffold(
          appBar: AppBar(title: Text(tr('hotel.home.title'))),
          floatingActionButton: hotelId == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddRootSectionDialog(context),
                  icon: const Icon(Icons.add_box_outlined),
                  label: Text(tr('hotel.home.addRootSection')),
                ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ربط الفندق
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeCtrl,
                        decoration: InputDecoration(
                          labelText: tr('hotel.home.enterCode'),
                          hintText: 'RMR001',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _resolving
                          ? null
                          : () => _resolveHotelByCode(context),
                      child: _resolving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(tr('hotel.home.linkHotel')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (hotelId == null)
                  Text(
                    tr('hotel.home.noHotelLinked'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Expanded(
                    child: _HotelServicesTree(
                      hotelId: hotelId,
                      onAddSub: (parent) =>
                          _showAddSubSectionDialog(context, parent),
                      onAddItem: (parentId, childId) => _showAddItemSheet(
                        context,
                        parentSectionId: parentId,
                        sectionId: childId,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HotelServicesTree extends StatelessWidget {
  _HotelServicesTree({
    required this.hotelId,
    required this.onAddSub,
    required this.onAddItem,
  });

  final String hotelId;
  final void Function(Section parent) onAddSub;
  final void Function(String parentSectionId, String sectionId) onAddItem;

  // نستخدم الريبو لأشياء فرعية (items/subs)،
  // بينما للجذور نستعمل استعلام واحد ثابت (isRoot == true) لمنع الوميض.
  final AdminServicesRepository repo = AdminServicesRepository();

  Stream<List<Section>> _rootSectionsStable(String hotelId) {
    final col = FirebaseFirestore.instance
        .collection('hotels')
        .doc(hotelId)
        .collection('service_sections');

    // استعلام واحد فقط: isRoot == true ثم order
    return col
        .where('isRoot', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => Section.fromDoc(d)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Section>>(
      stream: _rootSectionsStable(hotelId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final sections = snap.data ?? const [];
        if (sections.isEmpty) {
          return Center(child: Text(tr('common.noData')));
        }

        return ListView.separated(
          itemCount: sections.length,
          separatorBuilder: (_, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final s = sections[index];
            final title = s.name.resolve(
              context.locale.languageCode,
              fallback: s.name.en ?? s.name.ar ?? '',
            );

            return Card(
              child: ExpansionTile(
                leading: const Icon(Icons.room_service_outlined),
                title: Text(title),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => onAddSub(s),
                          icon: const Icon(Icons.subdirectory_arrow_right),
                          label: Text(tr('hotel.home.addSubSection')),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () =>
                              onAddItem(s.id, s.id), // عنصر تحت الجذري
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(tr('hotel.home.addItem')),
                        ),
                      ],
                    ),
                  ),

                  // الأقسام الفرعية تحت هذا الجذري
                  StreamBuilder<List<Section>>(
                    stream: repo.streamSubSections(hotelId, s.id),
                    builder: (context, subSnap) {
                      if (subSnap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: LinearProgressIndicator(),
                        );
                      }
                      if (subSnap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Error: ${subSnap.error}'),
                        );
                      }
                      final subs = subSnap.data ?? const [];
                      if (subs.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subs.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (context, subIdx) {
                          final sub = subs[subIdx];
                          final subTitle = sub.name.resolve(
                            context.locale.languageCode,
                            fallback: sub.name.en ?? sub.name.ar ?? '',
                          );

                          return Card(
                            margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                            child: ExpansionTile(
                              leading: const Icon(Icons.list_alt_outlined),
                              title: Text(subTitle),
                              children: [
                                // عناصر القسم الفرعي
                                StreamBuilder<List<Item>>(
                                  stream: repo.streamItems(hotelId, sub.id),
                                  builder: (context, itemSnap) {
                                    if (itemSnap.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: LinearProgressIndicator(),
                                      );
                                    }
                                    if (itemSnap.hasError) {
                                      return Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text('Error: ${itemSnap.error}'),
                                      );
                                    }
                                    final items = itemSnap.data ?? const [];
                                    if (items.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(tr('common.noItems')),
                                      );
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: items.length,
                                      separatorBuilder: (_, i) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, itemIndex) {
                                        final it = items[itemIndex];
                                        final name = it.name.resolve(
                                          context.locale.languageCode,
                                          fallback:
                                              it.name.en ?? it.name.ar ?? '',
                                        );
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.label_important_outline,
                                          ),
                                          title: Text(name),
                                          trailing: Text(
                                            '${it.price.toStringAsFixed(2)} ${it.currency}',
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                // إضافة عنصر لهذا الفرع
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    bottom: 12,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: TextButton.icon(
                                      onPressed: () => onAddItem(s.id, sub.id),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      label: Text(tr('hotel.home.addItem')),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // العناصر تحت الجذري مباشرة (إن وُجدت)
                  StreamBuilder<List<Item>>(
                    stream: repo.streamItems(hotelId, s.id),
                    builder: (context, itemSnap) {
                      if (itemSnap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: LinearProgressIndicator(),
                        );
                      }
                      if (itemSnap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Error: ${itemSnap.error}'),
                        );
                      }
                      final items = itemSnap.data ?? const [];
                      if (items.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (context, itemIndex) {
                          final it = items[itemIndex];
                          final name = it.name.resolve(
                            context.locale.languageCode,
                            fallback: it.name.en ?? it.name.ar ?? '',
                          );
                          return ListTile(
                            leading: const Icon(Icons.label_outline),
                            title: Text(name),
                            trailing: Text(
                              '${it.price.toStringAsFixed(2)} ${it.currency}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

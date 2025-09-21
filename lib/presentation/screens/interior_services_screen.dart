import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/item.dart';
import '../../data/models/localized_text.dart';
import '../../data/models/section.dart';
import '../../data/repositories/services_repository.dart';
import 'service_item_details_screen.dart';

class InteriorServicesArgs {
  final String hotelId;
  const InteriorServicesArgs({required this.hotelId, required String title});
}

class InteriorServicesScreen extends StatefulWidget {
  const InteriorServicesScreen({super.key});
  static const String routeName = '/interiorServices';

  @override
  State<InteriorServicesScreen> createState() => _InteriorServicesScreenState();
}

class _InteriorServicesScreenState extends State<InteriorServicesScreen> {
  final ServicesRepository repo = ServicesRepository();

  String? selectedRootId;
  String? selectedSubId;

  String _txt(LocalizedText t, BuildContext context) {
    return t.resolve(context.locale.languageCode, fallback: t.en ?? t.ar ?? '');
  }

  Future<bool> _sectionHasItems(String hotelId, String sectionId) async {
    final items = await repo.streamAvailableItems(hotelId, sectionId).first;
    return items.isNotEmpty;
  }

  Future<List<Section>> _filterRootsWithItems(
    String hotelId,
    List<Section> roots,
  ) async {
    final result = <Section>[];
    for (final r in roots) {
      // هل لدى الجذر عناصر مباشرة؟
      if (await _sectionHasItems(hotelId, r.id)) {
        result.add(r);
        continue;
      }
      // إن لم يكن لديه عناصر مباشرة، افحص فروعه:
      final subs = await repo.streamActiveSubSections(hotelId, r.id).first;
      for (final s in subs) {
        if (await _sectionHasItems(hotelId, s.id)) {
          result.add(r);
          break;
        }
      }
    }
    return result;
  }

  Future<List<Section>> _filterSubsWithItems(
    String hotelId,
    List<Section> subs,
  ) async {
    final out = <Section>[];
    for (final s in subs) {
      if (await _sectionHasItems(hotelId, s.id)) {
        out.add(s);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as InteriorServicesArgs?;
    final hotelId = args?.hotelId;

    if (hotelId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('home.sections.services'))),
        body: Center(child: Text(tr('hotel.home.noHotelLinked'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr('home.sections.services'))),
      body: StreamBuilder<List<Section>>(
        stream: repo.streamRootSectionsActive(hotelId),
        builder: (context, rootsSnap) {
          if (rootsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (rootsSnap.hasError) {
            return Center(child: Text('Error: ${rootsSnap.error}'));
          }
          final roots = rootsSnap.data ?? const <Section>[];
          if (roots.isEmpty) {
            return Center(child: Text(tr('common.noData')));
          }

          // نخفي الجذور التي لا تحتوي عناصر (لا مباشرة ولا عبر الفروع)
          return FutureBuilder<List<Section>>(
            future: _filterRootsWithItems(hotelId, roots),
            builder: (context, visRootsSnap) {
              if (visRootsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (visRootsSnap.hasError) {
                return Center(child: Text('Error: ${visRootsSnap.error}'));
              }
              final visibleRoots = visRootsSnap.data ?? const <Section>[];
              if (visibleRoots.isEmpty) {
                return Center(child: Text(tr('common.noData')));
              }

              selectedRootId ??= visibleRoots.first.id;
              final selectedRoot = visibleRoots.firstWhere(
                (r) => r.id == selectedRootId,
                orElse: () => visibleRoots.first,
              );

              // شريط الجذور (أفقي)
              final rootsBar = SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleRoots.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final r = visibleRoots[i];
                    final title = _txt(r.name, context);
                    final selected = r.id == selectedRootId;
                    return ChoiceChip(
                      selected: selected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title),
                          const SizedBox(width: 6),
                          const Icon(Icons.bed_outlined, size: 18),
                        ],
                      ),
                      onSelected: (v) {
                        if (!v) return;
                        setState(() {
                          selectedRootId = r.id;
                          selectedSubId = null;
                        });
                      },
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.10),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                    );
                  },
                ),
              );

              // فروع الجذر المختار (ثم نخفي منها ما لا يملك عناصر)
              return StreamBuilder<List<Section>>(
                stream: repo.streamActiveSubSections(hotelId, selectedRoot.id),
                builder: (context, subsSnap) {
                  if (subsSnap.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [rootsBar, const LinearProgressIndicator()],
                    );
                  }
                  if (subsSnap.hasError) {
                    return Column(
                      children: [
                        rootsBar,
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Error: ${subsSnap.error}'),
                        ),
                      ],
                    );
                  }
                  final subs = subsSnap.data ?? const <Section>[];

                  return FutureBuilder<List<Section>>(
                    future: _filterSubsWithItems(hotelId, subs),
                    builder: (context, visSubsSnap) {
                      final visibleSubs = visSubsSnap.data ?? const <Section>[];
                      final hasSubs = visibleSubs.isNotEmpty;

                      if (!hasSubs) selectedSubId = null;
                      if (hasSubs && selectedSubId == null) {
                        selectedSubId = visibleSubs.first.id;
                      }

                      final activeSectionId = selectedSubId ?? selectedRoot.id;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          rootsBar,

                          if (hasSubs)
                            SizedBox(
                              height: 48,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: visibleSubs.length,
                                separatorBuilder: (c, i) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final s = visibleSubs[i];
                                  final title = _txt(s.name, context);
                                  final selected = s.id == selectedSubId;
                                  return ChoiceChip(
                                    selected: selected,
                                    label: Text(title),
                                    onSelected: (v) {
                                      if (!v) return;
                                      setState(() => selectedSubId = s.id);
                                    },
                                    showCheckmark: false,
                                    labelStyle: TextStyle(
                                      color: selected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.08),
                                    selectedColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: StadiumBorder(
                                      side: BorderSide(
                                        color: selected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.20),
                                        width: 1.1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // العناصر للقسم النشط (الجذر إذا لا فروع، أو الفرع المختار)
                          Expanded(
                            child: StreamBuilder<List<Item>>(
                              stream: repo.streamAvailableItems(
                                hotelId,
                                activeSectionId,
                              ),
                              builder: (context, itemsSnap) {
                                if (itemsSnap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (itemsSnap.hasError) {
                                  return Center(
                                    child: Text('Error: ${itemsSnap.error}'),
                                  );
                                }
                                final items = itemsSnap.data ?? const <Item>[];
                                if (items.isEmpty) {
                                  return Center(
                                    child: Text(tr('common.noItems')),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: items.length,
                                  separatorBuilder: (c, i) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final it = items[i];
                                    final name = _txt(it.name, context);
                                    final sub = it.description == null
                                        ? null
                                        : _txt(it.description!, context);
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.label_important_outline,
                                      ),
                                      title: Text(name),
                                      subtitle: (sub == null || sub.isEmpty)
                                          ? null
                                          : Text(sub),
                                      trailing: Text(
                                        '${it.price.toStringAsFixed(2)} ${it.currency}',
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          ServiceItemDetailsScreen.routeName,
                                          arguments: ServiceItemDetailsArgs(
                                            hotelId: hotelId,
                                            item: it,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

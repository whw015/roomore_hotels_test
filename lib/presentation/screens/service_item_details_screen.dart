import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/item.dart';
import '../../data/models/localized_text.dart';
// للتوافق مع الثيم/الألوان المعتمدة لديك
// في حال احتجت أي توسيعات لاحقًا

// ========= Args =========
class ServiceItemDetailsArgs {
  final String hotelId;
  final Item item;
  const ServiceItemDetailsArgs({required this.hotelId, required this.item});
}

// ========= Cubit (State Management) =========
class ItemDetailsState {
  final int qty;
  final int? selectedOptionIndex;
  const ItemDetailsState({this.qty = 1, this.selectedOptionIndex});

  ItemDetailsState copyWith({int? qty, int? selectedOptionIndex}) {
    return ItemDetailsState(
      qty: qty ?? this.qty,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
    );
  }
}

class ItemDetailsCubit extends Cubit<ItemDetailsState> {
  ItemDetailsCubit() : super(const ItemDetailsState());

  void incQty() => emit(state.copyWith(qty: state.qty + 1));
  void decQty() => emit(state.copyWith(qty: state.qty > 1 ? state.qty - 1 : 1));
  void selectOption(int? idx) => emit(state.copyWith(selectedOptionIndex: idx));
}

// ========= UI =========
class ServiceItemDetailsScreen extends StatelessWidget {
  const ServiceItemDetailsScreen({super.key});
  static const String routeName = '/serviceItemDetails';

  String _txt(LocalizedText t, BuildContext context) {
    // يحترم لغة الواجهة (ar/en)، مع fallback
    return t.resolve(context.locale.languageCode, fallback: t.en ?? t.ar ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ServiceItemDetailsArgs?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('common.error'))),
        body: Center(child: Text(tr('common.missingHotelId'))),
      );
    }

    final item = args.item;
    final title = _txt(item.name, context);
    final description = (item.description == null)
        ? tr('details.no_desc')
        : _txt(item.description!, context).trim().isEmpty
        ? tr('details.no_desc')
        : _txt(item.description!, context);

    return BlocProvider(
      create: (_) => ItemDetailsCubit(),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          final primary = colorScheme.primary;

          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========== صور المنتج ==========
                _ItemImagesCarousel(imageUrls: item.imageUrls),

                // ========== محتوى ==========
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الاسم + السعر
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _PricePill(
                              priceText:
                                  '${item.price.toStringAsFixed(2)} ${item.currency}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // الوصف
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                        ),

                        // الخيارات (لو موجودة)
                        if ((item.options ?? const <dynamic>[]).isNotEmpty)
                          _OptionsBlock(options: item.options!),

                        const Divider(height: 28),
                        // الكمية + الإجمالي
                        _QtyAndTotalRow(item: item),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ========== زر الطلب الآن ==========
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      height: 52,
                      child: BlocBuilder<ItemDetailsCubit, ItemDetailsState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: Text(tr('cart.orderNow')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // هنا ممكن تربط مع CartCubit لو متوفر لديك في التطبيق
                              // مثال (اختياري):
                              // context.read<CartCubit>().addItem(item, qty: state.qty, optionIndex: state.selectedOptionIndex);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    tr('cart.added'),
                                    // مثال: "تمت الإضافة إلى السلة"
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ========= Widgets =========

class _ItemImagesCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ItemImagesCarousel({required this.imageUrls});

  @override
  State<_ItemImagesCarousel> createState() => _ItemImagesCarouselState();
}

class _ItemImagesCarouselState extends State<_ItemImagesCarousel> {
  final PageController controller = PageController();
  int current = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.imageUrls.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: hasImages
                ? PageView.builder(
                    controller: controller,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (i) => setState(() => current = i),
                    itemBuilder: (_, i) {
                      final url = widget.imageUrls[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, x, i) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 36,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
          ),
          if (hasImages)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.imageUrls.length, (i) {
                      final isActive = i == current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String priceText;
  const _PricePill({required this.priceText});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        priceText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OptionsBlock extends StatelessWidget {
  final List<dynamic> options;
  const _OptionsBlock({required this.options});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // نحاول تمثيل الخيارات كسلسلة نصية لو كانت String،
    // ولو كانت Map/أشكال أخرى، نعرض toString() بشكل لائق.
    final labels = options.map<String>((e) {
      if (e is String) return e;
      if (e is Map && e.containsKey('name')) return '${e['name']}';
      return e.toString();
    }).toList();

    return BlocBuilder<ItemDetailsCubit, ItemDetailsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              tr(
                'home.menu',
              ), // عنوان بسيط للخيارات (تقدر تغيّره لمفتاح أدق عندك)
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: -4,
              children: List.generate(labels.length, (i) {
                final selected = state.selectedOptionIndex == i;
                return ChoiceChip(
                  label: Text(labels[i]),
                  selected: selected,
                  onSelected: (v) => context
                      .read<ItemDetailsCubit>()
                      .selectOption(v ? i : null),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                  selectedColor: colorScheme.primary,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _QtyAndTotalRow extends StatelessWidget {
  final Item item;
  const _QtyAndTotalRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return BlocBuilder<ItemDetailsCubit, ItemDetailsState>(
      builder: (context, state) {
        final total = item.price * state.qty;

        return Row(
          children: [
            // الكمية
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Text(
                      tr('cart.quantity'),
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          context.read<ItemDetailsCubit>().decQty(),
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: '-',
                    ),
                    Text(
                      '${state.qty}',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          context.read<ItemDetailsCubit>().incQty(),
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: '+',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // الإجمالي
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tr('cart.total'),
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${total.toStringAsFixed(2)} ${item.currency}',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

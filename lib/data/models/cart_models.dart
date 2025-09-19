import 'item.dart';

class SelectedChoice {
  final String optionNameAr;
  final String optionNameEn;
  final String choiceNameAr;
  final String choiceNameEn;
  final double priceDelta;

  const SelectedChoice({
    required this.optionNameAr,
    required this.optionNameEn,
    required this.choiceNameAr,
    required this.choiceNameEn,
    required this.priceDelta,
  });

  // للمقارنة والتجميع
  String get hashKey => '${optionNameEn}_${choiceNameEn}_$priceDelta';
}

class CartLine {
  final Item item;
  final int quantity;
  final List<SelectedChoice> selections; // اختيار واحد لكل option (راديو)
  final String currency;

  const CartLine({
    required this.item,
    required this.quantity,
    required this.selections,
    required this.currency,
  });

  double get unitPrice {
    final deltas = selections.fold<double>(0, (acc, s) => acc + s.priceDelta);
    return item.price + deltas;
  }

  double get total => unitPrice * quantity;

  // مفتاح فريد لتجميع العناصر نفسها بنفس الاختيارات
  String get aggregateKey {
    final optsKey = selections.map((s) => s.hashKey).toList()..sort();
    return '${item.id}-${optsKey.join('|')}';
  }

  CartLine copyWith({int? quantity}) => CartLine(
    item: item,
    quantity: quantity ?? this.quantity,
    selections: selections,
    currency: currency,
  );
}

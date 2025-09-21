import 'package:equatable/equatable.dart';

import '../../../data/models/cart_models.dart';

class CartState extends Equatable {
  final List<CartLine> lines;

  const CartState({this.lines = const []});

  double get subtotal => lines.fold<double>(0, (acc, l) => acc + l.total);
  int get itemsCount => lines.fold<int>(0, (acc, l) => acc + l.quantity);

  @override
  List<Object?> get props => [lines, subtotal, itemsCount];
}

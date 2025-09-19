import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cart_models.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addLine(CartLine line) {
    final list = List<CartLine>.from(state.lines);
    final idx = list.indexWhere((l) => l.aggregateKey == line.aggregateKey);

    if (idx >= 0) {
      final existing = list[idx];
      list[idx] = existing.copyWith(
        quantity: existing.quantity + line.quantity,
      );
    } else {
      list.add(line);
    }
    emit(CartState(lines: list));
  }

  void removeAt(int index) {
    final list = List<CartLine>.from(state.lines)..removeAt(index);
    emit(CartState(lines: list));
  }

  void clear() => emit(const CartState());
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/guest.dart';
import '../../data/repositories/guest_repository.dart';

class GuestsState extends Equatable {
  final bool loading;
  final List<Guest> list;
  final String? error;

  const GuestsState({required this.loading, required this.list, this.error});

  factory GuestsState.initial() => const GuestsState(loading: false, list: <Guest>[]);

  GuestsState copyWith({bool? loading, List<Guest>? list, String? error}) {
    return GuestsState(
      loading: loading ?? this.loading,
      list: list ?? this.list,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, list, error];
}

class GuestsCubit extends Cubit<GuestsState> {
  final GuestRepository _repo;
  GuestsCubit(this._repo) : super(GuestsState.initial());

  Future<void> load({required String hotelId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await _repo.fetchAll(hotelId: hotelId);
      emit(state.copyWith(loading: false, list: data));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}


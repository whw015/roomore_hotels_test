import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/api_repository.dart';

class GuestsState extends Equatable {
  final bool isLoading;
  final List guests;
  final String? error;

  const GuestsState({
    this.isLoading = false,
    this.guests = const [],
    this.error,
  });

  GuestsState copyWith({bool? isLoading, List? guests, String? error}) {
    return GuestsState(
      isLoading: isLoading ?? this.isLoading,
      guests: guests ?? this.guests,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, guests, error];
}

class GuestsCubit extends Cubit<GuestsState> {
  final ApiRepository apiRepository;

  GuestsCubit(this.apiRepository) : super(const GuestsState()) {
    fetchGuests();
  }

  Future<void> fetchGuests() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await apiRepository.getGuests();
      emit(state.copyWith(isLoading: false, guests: response['guests']));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addGuest(Map<String, dynamic> data) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.addGuest(data);
      await fetchGuests();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteGuest(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.deleteGuest(id);
      await fetchGuests();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

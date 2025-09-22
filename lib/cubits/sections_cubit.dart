import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/api_repository.dart';

class SectionsState extends Equatable {
  final bool isLoading;
  final List sections;
  final String? error;

  const SectionsState({
    this.isLoading = false,
    this.sections = const [],
    this.error,
  });

  SectionsState copyWith({bool? isLoading, List? sections, String? error}) {
    return SectionsState(
      isLoading: isLoading ?? this.isLoading,
      sections: sections ?? this.sections,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, sections, error];
}

class SectionsCubit extends Cubit<SectionsState> {
  final ApiRepository apiRepository;

  SectionsCubit(this.apiRepository) : super(const SectionsState()) {
    fetchSections();
  }

  Future<void> fetchSections() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await apiRepository.getSections();
      emit(state.copyWith(isLoading: false, sections: response['sections']));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSection(Map<String, dynamic> data) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.addSection(data);
      await fetchSections();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteSection(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.deleteSection(id);
      await fetchSections();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

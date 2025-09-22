import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/api_repository.dart';

class WorkGroupsState extends Equatable {
  final bool isLoading;
  final List workGroups;
  final String? error;

  const WorkGroupsState({
    this.isLoading = false,
    this.workGroups = const [],
    this.error,
  });

  WorkGroupsState copyWith({bool? isLoading, List? workGroups, String? error}) {
    return WorkGroupsState(
      isLoading: isLoading ?? this.isLoading,
      workGroups: workGroups ?? this.workGroups,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, workGroups, error];
}

class WorkGroupsCubit extends Cubit<WorkGroupsState> {
  final ApiRepository apiRepository;

  WorkGroupsCubit(this.apiRepository) : super(const WorkGroupsState()) {
    fetchWorkGroups();
  }

  Future<void> fetchWorkGroups() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await apiRepository.getWorkGroups();
      emit(
        state.copyWith(isLoading: false, workGroups: response['work_groups']),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addWorkGroup(Map<String, dynamic> data) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.addWorkGroup(data);
      await fetchWorkGroups();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteWorkGroup(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.deleteWorkGroup(id);
      await fetchWorkGroups();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

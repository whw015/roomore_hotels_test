import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/api_repository.dart';
import '../../data/repositories/auth_repository.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isQrVerified;
  final String? userGroup;
  final List<dynamic> services;
  final List<String> permissions;
  final String? error;
  final dynamic stay; // من الكود الأصلي في home_sections_grid.dart

  const HomeState({
    this.isLoading = false,
    this.isQrVerified = false,
    this.userGroup,
    this.services = const [],
    this.permissions = const [],
    this.error,
    this.stay,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isQrVerified,
    String? userGroup,
    List<dynamic>? services,
    List<String>? permissions,
    String? error,
    dynamic stay,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isQrVerified: isQrVerified ?? this.isQrVerified,
      userGroup: userGroup ?? this.userGroup,
      services: services ?? this.services,
      permissions: permissions ?? this.permissions,
      error: error ?? this.error,
      stay: stay ?? this.stay,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isQrVerified,
    userGroup,
    services,
    permissions,
    error,
    stay,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  final ApiRepository apiRepository;
  final AuthRepository authRepository;

  HomeCubit(this.apiRepository, this.authRepository) : super(const HomeState());

  Future<void> verifyQrCode(String qrCode, String userId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await apiRepository.checkEmployee(userId, qrCode);
      if (result['is_employee']) {
        final data = await apiRepository.getUserGroupAndServices(
          userId,
          result['hotel_id'],
        );
        emit(
          state.copyWith(
            isLoading: false,
            isQrVerified: true,
            userGroup: data['group'],
            services: data['services'],
            permissions: data['permissions'],
            stay: {'hotelId': result['hotel_id']}, // تحديث stay
          ),
        );
        if (data['group'] == 'admin') {
          emit(state.copyWith(permissions: ['full_access']));
        }
      } else {
        emit(state.copyWith(isLoading: false, isQrVerified: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // وظائف أخرى موجودة في الكود الأصلي...
}

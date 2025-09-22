import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/app_preferences_repository.dart';
import '../../data/repositories/auth_repository.dart';
import 'app_flow_state.dart';

class AppFlowCubit extends Cubit<AppFlowState> {
  AppFlowCubit(this._preferencesRepository, this._authRepository)
    : super(const AppFlowState.initial()) {
    _authSubscription = _authRepository.authStateChanges().listen(
      _handleAuthChange,
    );
  }

  final AppPreferencesRepository _preferencesRepository;
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  Future<void> refreshFlow() async {
    emit(state.copyWith(isLoading: true));
    final languageCode = await _preferencesRepository.getSelectedLanguageCode();
    final loggedIn = _authRepository.currentUser != null;

    final status = _resolveStatus(
      hasLanguage: languageCode != null,
      isLoggedIn: loggedIn,
    );

    emit(
      state.copyWith(
        status: status,
        hasSelectedLanguage: languageCode != null,
        isLoggedIn: loggedIn,
        isLoading: false,
      ),
    );
  }

  Future<void> saveLanguage(String code) async {
    await _preferencesRepository.saveLanguageCode(code);
    await refreshFlow();
  }

  AppFlowStatus _resolveStatus({
    required bool hasLanguage,
    required bool isLoggedIn,
  }) {
    if (!hasLanguage) {
      return AppFlowStatus.languageSelection;
    }
    if (!isLoggedIn) {
      return AppFlowStatus.authentication;
    }
    return AppFlowStatus.home;
  }

  void _handleAuthChange(User? user) {
    final hasLanguage = state.hasSelectedLanguage;
    final status = _resolveStatus(
      hasLanguage: hasLanguage,
      isLoggedIn: user != null,
    );
    emit(state.copyWith(status: status, isLoggedIn: user != null));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

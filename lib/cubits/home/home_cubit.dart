import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/hotel_code_result.dart';
import '../../../data/models/home_hotel_stay.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required AuthRepository authRepository,
    required HomeRepository homeRepository,
  }) : _authRepository = authRepository,
       _homeRepository = homeRepository,
       super(const HomeState.initial()) {
    _initialize();
  }

  final AuthRepository _authRepository;
  final HomeRepository _homeRepository;
  StreamSubscription<HomeHotelStay?>? _staySubscription;

  void _initialize() {
    final user = _authRepository.currentUser;
    final names = _splitName(user?.displayName, user?.email);
    emit(
      state.copyWith(
        status: HomeContentStatus.loading,
        firstName: names.$1,
        lastName: names.$2,
        clearMessage: true,
        isCheckingOut: false,
      ),
    );

    final userId = user?.uid ?? '';
    if (userId.isEmpty) {
      emit(state.copyWith(status: HomeContentStatus.showQr, stay: null, isCheckingOut: false));
      return;
    }

    _staySubscription = _homeRepository
        .watchCurrentStay(userId: userId)
        .listen(_handleStayUpdate, onError: _handleStayError);
  }

  Future<void> verifyHotelCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) {
      emit(
        state.copyWith(
          messageKey: 'home.messages.enter_code',
          messageArgs: null,
          isVerifying: false,
          isCheckingOut: false,
          status: HomeContentStatus.showQr,
        ),
      );
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          messageKey: 'errors.unauthorized',
          messageArgs: null,
          status: HomeContentStatus.showQr,
          isCheckingOut: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isVerifying: true, clearMessage: true, isCheckingOut: false));

    final result = await _homeRepository.verifyHotelCode(
      userId: user.uid,
      code: code,
    );

    switch (result.outcome) {
      case HotelCodeOutcome.guestActive:
        emit(
          state.copyWith(
            status: HomeContentStatus.showSections,
            stay: result.stay,
            messageKey: null,
            messageArgs: null,
            isVerifying: false,
            isCheckingOut: false,
          ),
        );
        break;
      case HotelCodeOutcome.notGuest:
        emit(
          state.copyWith(
            status: HomeContentStatus.showQr,
            stay: null,
            messageKey: result.messageKey ?? 'home.messages.not_guest',
            messageArgs: result.messageArgs,
            isVerifying: false,
            isCheckingOut: false,
          ),
        );
        break;
      case HotelCodeOutcome.hotelNotFound:
        emit(
          state.copyWith(
            status: HomeContentStatus.showQr,
            stay: null,
            messageKey: result.messageKey ?? 'home.messages.hotel_not_found',
            messageArgs: result.messageArgs,
            isVerifying: false,
            isCheckingOut: false,
          ),
        );
        break;
      case HotelCodeOutcome.error:
        emit(
          state.copyWith(
            status: HomeContentStatus.showQr,
            stay: null,
            messageKey: result.messageKey ?? 'unknown_error',
            messageArgs: result.messageArgs,
            isVerifying: false,
            isCheckingOut: false,
          ),
        );
        break;
    }
  }

  Future<void> checkOutFromHotel() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          messageKey: 'errors.unauthorized',
          messageArgs: null,
          isCheckingOut: false,
        ),
      );
      return;
    }

    final stay = state.stay;
    if (stay == null) {
      emit(
        state.copyWith(
          status: HomeContentStatus.showQr,
          messageKey: 'home.messages.no_active_stay',
          messageArgs: null,
          isCheckingOut: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isCheckingOut: true, clearMessage: true));

    final errorKey = await _homeRepository.checkOutFromHotel(
      userId: user.uid,
      stay: stay,
    );

    if (errorKey == null) {
      emit(
        state.copyWith(
          status: HomeContentStatus.showQr,
          stay: null,
          messageKey: 'home.messages.checkout_success',
          messageArgs: {'hotel': stay.hotelName},
          isCheckingOut: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isCheckingOut: false,
          messageKey: errorKey,
          messageArgs: null,
        ),
      );
    }
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true, isCheckingOut: false));
  }

  void _handleStayUpdate(HomeHotelStay? stay) {
    if (stay == null) {
      emit(state.copyWith(status: HomeContentStatus.showQr, stay: null, isCheckingOut: false));
      return;
    }

    if (stay.isActive) {
      emit(
        state.copyWith(
          status: HomeContentStatus.showSections,
          stay: stay,
          clearMessage: true,
          isCheckingOut: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: HomeContentStatus.showQr,
          stay: stay,
          messageKey: 'home.messages.not_guest',
          messageArgs: const {},
          isCheckingOut: false,
        ),
      );
    }
  }

  void _handleStayError(Object error) {
    emit(
      state.copyWith(
        status: HomeContentStatus.error,
        messageKey: 'unknown_error',
        messageArgs: null,
        stay: null,
        isCheckingOut: false,
      ),
    );
  }

  (String, String) _splitName(String? displayName, String? email) {
    final fallback = email?.split('@').first ?? '';
    final name = (displayName ?? '').trim();
    if (name.isEmpty) {
      if (fallback.isEmpty) {
        return ('Guest', '');
      }
      final parts = fallback.split(' ');
      if (parts.length == 1) {
        return (parts.first, '');
      }
      return (parts.first, parts.sublist(1).join(' '));
    }
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }

  @override
  Future<void> close() {
    _staySubscription?.cancel();
    return super.close();
  }
}
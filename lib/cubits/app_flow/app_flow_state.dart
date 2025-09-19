import 'package:flutter/foundation.dart';

enum AppFlowStatus {
  initial,
  languageSelection,
  authentication,
  home,
}

@immutable
class AppFlowState {
  const AppFlowState({
    required this.status,
    required this.hasSelectedLanguage,
    required this.isLoggedIn,
    this.isLoading = false,
  });

  const AppFlowState.initial()
      : status = AppFlowStatus.initial,
        hasSelectedLanguage = false,
        isLoggedIn = false,
        isLoading = true;

  final AppFlowStatus status;
  final bool hasSelectedLanguage;
  final bool isLoggedIn;
  final bool isLoading;

  AppFlowState copyWith({
    AppFlowStatus? status,
    bool? hasSelectedLanguage,
    bool? isLoggedIn,
    bool? isLoading,
  }) {
    return AppFlowState(
      status: status ?? this.status,
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFlowState &&
        other.status == status &&
        other.hasSelectedLanguage == hasSelectedLanguage &&
        other.isLoggedIn == isLoggedIn &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(
        status,
        hasSelectedLanguage,
        isLoggedIn,
        isLoading,
      );
}

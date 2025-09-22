import '../../data/models/home_hotel_stay.dart';

enum HomeContentStatus { initial, loading, showQr, showSections, error }

class HomeState {
  const HomeState({
    required this.status,
    required this.firstName,
    required this.lastName,
    this.stay,
    this.messageKey,
    this.messageArgs,
    this.isVerifying = false,
    this.isCheckingOut = false,
  });

  const HomeState.initial()
    : status = HomeContentStatus.initial,
      firstName = '',
      lastName = '',
      stay = null,
      messageKey = null,
      messageArgs = null,
      isVerifying = false,
      isCheckingOut = false;

  final HomeContentStatus status;
  final String firstName;
  final String lastName;
  final HomeHotelStay? stay;
  final String? messageKey;
  final Map<String, String>? messageArgs;
  final bool isVerifying;
  final bool isCheckingOut;

  bool get showSections => status == HomeContentStatus.showSections;

  HomeState copyWith({
    HomeContentStatus? status,
    String? firstName,
    String? lastName,
    HomeHotelStay? stay,
    String? messageKey,
    Map<String, String>? messageArgs,
    bool? isVerifying,
    bool? isCheckingOut,
    bool clearMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      stay: stay ?? this.stay,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      messageArgs: clearMessage ? null : (messageArgs ?? this.messageArgs),
      isVerifying: isVerifying ?? this.isVerifying,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
    );
  }
}

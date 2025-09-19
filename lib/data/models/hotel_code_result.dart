import 'home_hotel_stay.dart';

enum HotelCodeOutcome { guestActive, notGuest, hotelNotFound, error }

class HotelCodeResult {
  const HotelCodeResult({
    required this.outcome,
    this.stay,
    this.messageKey,
    this.messageArgs,
  });

  final HotelCodeOutcome outcome;
  final HomeHotelStay? stay;
  final String? messageKey;
  final Map<String, String>? messageArgs;

  HotelCodeResult copyWith({
    HotelCodeOutcome? outcome,
    HomeHotelStay? stay,
    String? messageKey,
    Map<String, String>? messageArgs,
  }) {
    return HotelCodeResult(
      outcome: outcome ?? this.outcome,
      stay: stay ?? this.stay,
      messageKey: messageKey ?? this.messageKey,
      messageArgs: messageArgs ?? this.messageArgs,
    );
  }

  static HotelCodeResult guest(HomeHotelStay stay) =>
      HotelCodeResult(outcome: HotelCodeOutcome.guestActive, stay: stay);

  static HotelCodeResult notGuest({String? messageKey}) => HotelCodeResult(
    outcome: HotelCodeOutcome.notGuest,
    messageKey: messageKey,
  );

  static HotelCodeResult hotelNotFound({String? messageKey}) => HotelCodeResult(
    outcome: HotelCodeOutcome.hotelNotFound,
    messageKey: messageKey,
  );

  static HotelCodeResult error({String? messageKey}) =>
      HotelCodeResult(outcome: HotelCodeOutcome.error, messageKey: messageKey);
}

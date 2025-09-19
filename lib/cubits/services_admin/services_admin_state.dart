
import 'package:equatable/equatable.dart';

class ServicesAdminState extends Equatable {
  const ServicesAdminState({
    this.hotelId,
    this.isBusy = false,
    this.errorMessage,
  });

  final String? hotelId;
  final bool isBusy;
  final String? errorMessage;

  ServicesAdminState copyWith({
    String? hotelId,
    bool? isBusy,
    String? errorMessage,
  }) {
    return ServicesAdminState(
      hotelId: hotelId ?? this.hotelId,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [hotelId, isBusy, errorMessage];
}

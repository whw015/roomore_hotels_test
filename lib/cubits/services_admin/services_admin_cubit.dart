// importاتك المعتادة...
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_services_repository.dart';
import '../../data/models/item.dart';
import 'services_admin_state.dart';

class ServicesAdminCubit extends Cubit<ServicesAdminState> {
  final AdminServicesRepository _repo;
  ServicesAdminCubit(this._repo) : super(const ServicesAdminState());

  void setHotelId(String hotelId) {
    emit(state.copyWith(hotelId: hotelId));
  }

  Future<void> addRootSection({
    required String nameAr,
    required String nameEn,
    required int order,
    required bool isActive,
  }) async {
    final hotelId = state.hotelId;
    if (hotelId == null) return;
    await _repo.addRootSection(
      hotelId: hotelId,
      nameAr: nameAr,
      nameEn: nameEn,
      order: order,
      isActive: isActive,
    );
  }

  Future<void> addSubSection({
    required String parentSectionId,
    required String nameAr,
    required String nameEn,
    required int order,
    required bool isActive,
  }) async {
    final hotelId = state.hotelId;
    if (hotelId == null) return;
    await _repo.addSubSection(
      hotelId: hotelId,
      parentSectionId: parentSectionId,
      nameAr: nameAr,
      nameEn: nameEn,
      order: order,
      isActive: isActive,
    );
  }

  /// التوقيع الفعلي الذي نحتاجه الآن
  Future<void> addItem({
    required String sectionId,
    required Item item,
    String? parentSectionId, // اختياري لو أردت تخزينه مع العنصر
  }) async {
    final hotelId = state.hotelId;
    if (hotelId == null) return;
    await _repo.addItem(
      hotelId: hotelId,
      sectionId: sectionId,
      item: item,
      parentSectionId: parentSectionId,
    );
  }
}

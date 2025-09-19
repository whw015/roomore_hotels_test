// lib/data/repositories/firestore_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  final FirebaseFirestore firestore;
  FirestoreRepository({required this.firestore});

  /// يحاول أولاً hotels/{code}، وإن لم يجد؛ يبحث where code == {code}.
  Future<String?> resolveHotelIdByCode(String code) async {
    final raw = code.trim();
    if (raw.isEmpty) return null;

    // إن كنت تخزن الأكواد بحروف كبيرة فقط، فعّل السطر التالي:
    final normalized = raw.toUpperCase();

    // 1) جرّب الوثيقة مباشرةً: hotels/{code}
    final directDoc = await firestore
        .collection('hotels')
        .doc(normalized)
        .get();

    if (directDoc.exists) {
      return directDoc.id; // هنا ستُعيد "RMR001"
    }

    // 2) إن لم توجد، ابحث بالحقل code
    final q = await firestore
        .collection('hotels')
        .where('code', isEqualTo: normalized)
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) {
      return q.docs.first.id;
    }

    // لم يُعثر على الفندق
    return null;
  }
}

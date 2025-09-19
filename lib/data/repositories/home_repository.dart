import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favorite_item.dart';
import '../models/home_hotel_stay.dart';
import '../models/hotel_code_result.dart';
import '../models/order_summary.dart';
import '../models/quick_action_item.dart';
import '../models/recommendation_item.dart';

class HomeRepository {
  HomeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<QuickActionItem>> watchQuickActions() async* {
    yield _quickActionsFallback;
    try {
      final snapshots = _firestore
          .collection('quick_actions')
          .orderBy('priority', descending: false)
          .snapshots();
      await for (final snapshot in snapshots) {
        if (snapshot.docs.isEmpty) {
          yield _quickActionsFallback;
        } else {
          yield snapshot.docs
              .map((doc) => QuickActionItem.fromMap(doc.id, doc.data()))
              .toList();
        }
      }
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        yield _quickActionsFallback;
        return;
      }
      log('Failed to load quick actions', error: error, stackTrace: stackTrace);
      yield _quickActionsFallback;
    } catch (error, stackTrace) {
      log('Failed to load quick actions', error: error, stackTrace: stackTrace);
      yield _quickActionsFallback;
    }
  }

  Stream<List<RecommendationItem>> watchRecommendations() async* {
    yield _recommendationsFallback;
    try {
      final snapshots = _firestore
          .collection('recommendations')
          .orderBy('priority', descending: false)
          .snapshots();
      await for (final snapshot in snapshots) {
        if (snapshot.docs.isEmpty) {
          yield _recommendationsFallback;
        } else {
          yield snapshot.docs
              .map((doc) => RecommendationItem.fromMap(doc.id, doc.data()))
              .toList();
        }
      }
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        yield _recommendationsFallback;
        return;
      }
      log(
        'Failed to load recommendations',
        error: error,
        stackTrace: stackTrace,
      );
      yield _recommendationsFallback;
    } catch (error, stackTrace) {
      log(
        'Failed to load recommendations',
        error: error,
        stackTrace: stackTrace,
      );
      yield _recommendationsFallback;
    }
  }

  Stream<List<OrderSummary>> watchOrders({required String userId}) async* {
    if (userId.isEmpty) {
      yield _ordersFallback;
      return;
    }
    try {
      final query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
      await for (final snapshot in query.snapshots()) {
        if (snapshot.docs.isEmpty) {
          yield const [];
        } else {
          yield snapshot.docs.map(_orderFromDoc).toList();
        }
      }
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        yield _ordersFallback;
        return;
      }
      log('Failed to load orders', error: error, stackTrace: stackTrace);
      yield _ordersFallback;
    } catch (error, stackTrace) {
      log('Failed to load orders', error: error, stackTrace: stackTrace);
      yield _ordersFallback;
    }
  }

  Stream<List<FavoriteItem>> watchFavorites({required String userId}) async* {
    if (userId.isEmpty) {
      yield _favoritesFallback;
      return;
    }
    try {
      final query = _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
      await for (final snapshot in query.snapshots()) {
        if (snapshot.docs.isEmpty) {
          yield const [];
        } else {
          yield snapshot.docs
              .map((doc) => FavoriteItem.fromMap(doc.id, doc.data()))
              .toList();
        }
      }
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        yield _favoritesFallback;
        return;
      }
      log('Failed to load favorites', error: error, stackTrace: stackTrace);
      yield _favoritesFallback;
    } catch (error, stackTrace) {
      log('Failed to load favorites', error: error, stackTrace: stackTrace);
      yield _favoritesFallback;
    }
  }

  Stream<HomeHotelStay?> watchCurrentStay({required String userId}) async* {
    if (userId.isEmpty) {
      yield null;
      return;
    }
    final doc = _firestore.collection('user_stays').doc(userId);
    try {
      await for (final snapshot in doc.snapshots()) {
        if (!snapshot.exists) {
          yield null;
        } else {
          final data = snapshot.data() ?? <String, dynamic>{};
          final stay = HomeHotelStay.fromFirestore(snapshot.id, data);
          final enrichedStay = await _resolveStayHotelNames(stay);
          yield enrichedStay;
        }
      }
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        log(
          'User stay listener permission denied',
          error: error,
          stackTrace: stackTrace,
        );
        yield null;
        return;
      }
      log('User stay listener failed', error: error, stackTrace: stackTrace);
      yield null;
    } catch (error, stackTrace) {
      log('User stay listener failed', error: error, stackTrace: stackTrace);
      yield null;
    }
  }

  Future<HomeHotelStay> _resolveStayHotelNames(HomeHotelStay stay) async {
    final trimmedCode = stay.hotelCode.trim();
    final trimmedHotelId = stay.hotelId.trim();
    final trimmedName = stay.hotelName.trim();

    final hasArabic = stay.hotelNameAr?.trim().isNotEmpty ?? false;
    final hasEnglish = stay.hotelNameEn?.trim().isNotEmpty ?? false;
    final nameLooksLikeCode =
        trimmedName.isEmpty ||
        (trimmedCode.isNotEmpty &&
            trimmedName.toUpperCase() == trimmedCode.toUpperCase());

    if (hasArabic && hasEnglish && !nameLooksLikeCode) {
      return stay;
    }

    if (trimmedCode.isEmpty && trimmedHotelId.isEmpty) {
      return stay;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>>? hotelSnapshot;

      if (trimmedHotelId.isNotEmpty) {
        hotelSnapshot = await _firestore
            .collection('hotels')
            .doc(trimmedHotelId)
            .get();
      }
      if ((hotelSnapshot == null || !hotelSnapshot.exists) &&
          trimmedCode.isNotEmpty &&
          trimmedHotelId != trimmedCode) {
        hotelSnapshot = await _firestore
            .collection('hotels')
            .doc(trimmedCode)
            .get();
      }
      if ((hotelSnapshot == null || !hotelSnapshot.exists) &&
          trimmedCode.isNotEmpty) {
        final query = await _firestore
            .collection('hotels')
            .where('code', isEqualTo: trimmedCode)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          hotelSnapshot = query.docs.first;
        }
      }
      if (hotelSnapshot == null || !hotelSnapshot.exists) {
        return stay;
      }

      final data = hotelSnapshot.data() ?? <String, dynamic>{};

      String? asString(dynamic value) {
        if (value == null) {
          return null;
        }
        final text = value.toString().trim();
        return text.isEmpty ? null : text;
      }

      String selectMandatory(String? value, String fallback) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return fallback;
        }
        return trimmed;
      }

      String? selectOptional(String? value, String? fallback) {
        final trimmed = value?.trim();
        if (trimmed == null || trimmed.isEmpty) {
          return fallback;
        }
        return trimmed;
      }

      final resolvedAr = asString(data['hotelNameAr'] ?? data['nameAr']);
      final resolvedEn = asString(data['hotelNameEn'] ?? data['nameEn']);
      final resolvedBase = asString(data['hotelName'] ?? data['name']);
      final resolvedId = asString(data['hotelId']) ?? hotelSnapshot.id;

      final preferredName =
          resolvedBase ?? resolvedEn ?? resolvedAr ?? stay.hotelName;
      final resolvedHotelName = selectMandatory(preferredName, stay.hotelName);
      final resolvedHotelId = selectMandatory(resolvedId, stay.hotelId);

      return stay.copyWith(
        hotelId: resolvedHotelId,
        hotelName: resolvedHotelName,
        hotelNameAr: selectOptional(resolvedAr, stay.hotelNameAr),
        hotelNameEn: selectOptional(resolvedEn, stay.hotelNameEn),
      );
    } catch (error, stackTrace) {
      log(
        'Failed to load hotel names for stay ${stay.hotelId} (${stay.hotelCode})',
        error: error,
        stackTrace: stackTrace,
      );
      return stay;
    }
  }

  Future<HotelCodeResult> verifyHotelCode({
    required String userId,
    required String code,
  }) async {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      return HotelCodeResult.error(messageKey: 'home.messages.enter_code');
    }
    if (userId.isEmpty) {
      return HotelCodeResult.error(messageKey: 'errors.unauthorized');
    }
    try {
      final normalizedCode = trimmedCode.toUpperCase();
      DocumentSnapshot<Map<String, dynamic>> hotelDoc = await _firestore
          .collection('hotels')
          .doc(normalizedCode)
          .get();
      if (!hotelDoc.exists) {
        final query = await _firestore
            .collection('hotels')
            .where('code', isEqualTo: normalizedCode)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          return HotelCodeResult.hotelNotFound(
            messageKey: 'home.messages.hotel_not_found',
          );
        }
        hotelDoc = query.docs.first;
      }

      final hotelData = hotelDoc.data() ?? <String, dynamic>{};
      final hotelId = hotelDoc.id;

      String? asString(dynamic value) {
        if (value == null) {
          return null;
        }
        final text = value.toString().trim();
        return text.isEmpty ? null : text;
      }

      final guestsRef = _firestore
          .collection('hotels')
          .doc(hotelId)
          .collection('guests')
          .doc(userId);
      final guestDoc = await guestsRef.get();
      if (!guestDoc.exists) {
        await _safeDeleteUserStay(userId);
        return HotelCodeResult.notGuest(messageKey: 'home.messages.not_guest');
      }

      final guestData = guestDoc.data() ?? <String, dynamic>{};
      final rawStatus = (asString(guestData['status']) ?? '').toLowerCase();
      final isActive = guestData['isActive'] is bool
          ? guestData['isActive'] as bool
          : rawStatus == 'active' || rawStatus == 'in';
      final roomNumber =
          asString(guestData['roomNumber'] ?? guestData['room']) ?? '';

      final hotelCode = asString(hotelData['code']) ?? hotelId;
      final hotelNameAr = asString(
        hotelData['hotelNameAr'] ?? hotelData['nameAr'],
      );
      final hotelNameEn = asString(
        hotelData['hotelNameEn'] ?? hotelData['nameEn'],
      );
      final hotelName =
          asString(hotelData['hotelName'] ?? hotelData['name']) ??
          hotelNameEn ??
          hotelNameAr ??
          hotelCode;

      final stay = HomeHotelStay(
        hotelId: asString(hotelData['hotelId']) ?? hotelId,
        hotelCode: hotelCode,
        hotelName: hotelName,
        roomNumber: roomNumber,
        isActive: isActive,
        hotelNameAr: hotelNameAr,
        hotelNameEn: hotelNameEn,
        status: rawStatus.isEmpty ? null : rawStatus,
        updatedAt: DateTime.now(),
      );

      if (isActive) {
        final stayPayload = <String, dynamic>{
          'hotelId': stay.hotelId,
          'hotelCode': stay.hotelCode,
          'hotelName': stay.hotelName,
          'roomNumber': stay.roomNumber,
          'status': stay.status ?? 'active',
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (stay.hotelNameAr != null) {
          stayPayload['hotelNameAr'] = stay.hotelNameAr;
        }
        if (stay.hotelNameEn != null) {
          stayPayload['hotelNameEn'] = stay.hotelNameEn;
        }
        await _firestore
            .collection('user_stays')
            .doc(userId)
            .set(stayPayload, SetOptions(merge: true));
        return HotelCodeResult.guest(stay);
      } else {
        await _safeDeleteUserStay(userId);
        return HotelCodeResult.notGuest(messageKey: 'home.messages.not_guest');
      }
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        log(
          'Hotel code verification denied',
          error: error,
          stackTrace: stackTrace,
        );
        return HotelCodeResult.error(messageKey: 'errors.permission_denied');
      }
      log(
        'Hotel code verification failed',
        error: error,
        stackTrace: stackTrace,
      );
      return HotelCodeResult.error(messageKey: 'unknown_error');
    } catch (error, stackTrace) {
      log(
        'Hotel code verification failed',
        error: error,
        stackTrace: stackTrace,
      );
      return HotelCodeResult.error(messageKey: 'unknown_error');
    }
  }

  Future<void> _safeDeleteUserStay(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    try {
      final ref = _firestore.collection('user_stays').doc(userId);
      await ref.delete();
    } on FirebaseException catch (error, stackTrace) {
      if (error.code != 'not-found') {
        log('Failed to delete user stay', error: error, stackTrace: stackTrace);
      }
    } catch (error, stackTrace) {
      log('Failed to delete user stay', error: error, stackTrace: stackTrace);
    }
  }

  Future<String?> checkOutFromHotel({
    required String userId,
    required HomeHotelStay stay,
  }) async {
    if (userId.isEmpty) {
      return 'errors.unauthorized';
    }
    try {
      final batch = _firestore.batch();
      final stayRef = _firestore.collection('user_stays').doc(userId);
      batch.delete(stayRef);

      final hotelId = stay.hotelId.trim();
      if (hotelId.isNotEmpty) {
        final guestRef = _firestore
            .collection('hotels')
            .doc(hotelId)
            .collection('guests')
            .doc(userId);
        batch.set(guestRef, <String, dynamic>{
          'isActive': false,
          'status': 'checked_out',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      return null;
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        log('Checkout denied', error: error, stackTrace: stackTrace);
        return 'errors.permission_denied';
      }
      log('Checkout failed', error: error, stackTrace: stackTrace);
      return 'unknown_error';
    } catch (error, stackTrace) {
      log('Checkout failed', error: error, stackTrace: stackTrace);
      return 'unknown_error';
    }
  }

  OrderSummary _orderFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    DateTime createdAt;
    final createdRaw = data['createdAt'];
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    } else {
      createdAt = DateTime.now();
    }

    final reference = (data['reference'] as String?)?.trim();
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final status = (data['status'] as String?)?.trim();
    final statusColor = (data['statusColor'] as String?)?.trim();

    return OrderSummary(
      id: doc.id,
      reference: (reference == null || reference.isEmpty) ? doc.id : reference,
      createdAt: createdAt,
      total: total,
      status: (status == null || status.isEmpty) ? 'unknown' : status,
      statusColorHex: (statusColor == null || statusColor.isEmpty)
          ? '#FFA726'
          : statusColor,
    );
  }

  static const List<QuickActionItem> _quickActionsFallback = <QuickActionItem>[
    QuickActionItem(
      id: 'orders',
      label: 'My Orders',
      iconName: 'shopping_bag',
      route: 'orders',
    ),
    QuickActionItem(
      id: 'support',
      label: 'Support',
      iconName: 'support_agent',
      route: 'support',
    ),
    QuickActionItem(
      id: 'services',
      label: 'Services',
      iconName: 'room_service',
      route: 'services',
    ),
  ];

  static const List<RecommendationItem> _recommendationsFallback =
      <RecommendationItem>[
        RecommendationItem(
          id: 'spa',
          title: 'Spa treatment',
          description: 'Relaxing spa experience available now',
          iconName: 'spa',
        ),
        RecommendationItem(
          id: 'dining',
          title: 'Fine dining',
          description: 'Reserve a table at our signature restaurant',
          iconName: 'restaurant',
        ),
        RecommendationItem(
          id: 'tour',
          title: 'City tour',
          description: 'Discover nearby attractions with a guided tour',
          iconName: 'tour',
        ),
      ];

  static const List<OrderSummary> _ordersFallback = <OrderSummary>[];
  static const List<FavoriteItem> _favoritesFallback = <FavoriteItem>[];
}

<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

// ✅ استخدم نفس البوتستراب النشيط مع verify_qr.php
require_once __DIR__ . '/../bootstrap.php';

/**
 * ⚠️ للتجربة فقط: سماح بتمرير user_id بدون JWT (عطّله في الإنتاج)
 * اختبر عبر:
 *   ?hotel=alsaadah&debug_uid=1
 * أو هيدر:
 *   X-User-Id: 1
 */
const ROOMORE_DEBUG_ALLOW_UID = false;

function roomore_get_user_id(): int {
  // 1) وضع التطوير
  if (ROOMORE_DEBUG_ALLOW_UID) {
    $hdrUid = isset($_SERVER['HTTP_X_USER_ID']) ? (int)$_SERVER['HTTP_X_USER_ID'] : 0;
    $qsUid  = isset($_GET['debug_uid']) ? (int)$_GET['debug_uid'] : 0;
    $uid = $hdrUid > 0 ? $hdrUid : $qsUid;
    if ($uid > 0) return $uid;
  }
  // 2) JWT من البوتستراب (سيقرأ Authorization: Bearer ...)
  if (function_exists('require_auth')) {
    $u = require_auth(); // يجب أن يرجع ['id'=>...]
    $uid = (int)($u['id'] ?? 0);
    if ($uid > 0) return $uid;
  }
  // 3) فشل مصادقة
  json_response(401, ['ok'=>false, 'error'=>'unauthorized']);
  return 0;
}

/** المدخلات */
$h = isset($_GET['hotel']) ? strtolower(trim((string)$_GET['hotel'])) : '';
if ($h === '') { json_response(200, ['ok'=>false,'error'=>'invalid_hotel']); }

try {
  $user_id = roomore_get_user_id();

  // 1) hotels.slug
  $stmt = $pdo->prepare('SELECT id, slug, name FROM hotels WHERE slug = :s LIMIT 1');
  $stmt->execute([':s'=>$h]);
  $hotel = $stmt->fetch();

  // 2) أو alias في hotel_qr_codes.code
  if (!$hotel) {
    $stmt = $pdo->prepare("
      SELECT h.id, h.slug, h.name
      FROM hotel_qr_codes q
      JOIN hotels h ON h.id = q.hotel_id
      WHERE q.code = :c
      LIMIT 1
    ");
    $stmt->execute([':c'=>$h]);
    $hotel = $stmt->fetch();
  }

  if (!$hotel) {
    json_response(200, ['ok'=>false,'error'=>'hotel_not_found']);
  }

  $hotel_id = (int)$hotel['id'];

  // 3) نزيل فعّال وتواريخ تشمل اليوم
  $stmt = $pdo->prepare("
    SELECT room_number, status, check_in, check_out
    FROM hotel_guests
    WHERE hotel_id = :hid
      AND user_id  = :uid
      AND status IN ('active','checked_in')
      AND (DATE(NOW()) BETWEEN DATE(check_in) AND DATE(check_out))
    ORDER BY id DESC
    LIMIT 1
  ");
  $stmt->execute([':hid'=>$hotel_id, ':uid'=>$user_id]);
  $guest = $stmt->fetch();

  if (!$guest) {
    json_response(200, ['ok'=>false,'error'=>'not_guest']);
  }

  json_response(200, [
    'ok' => true,
    'guest' => [
      'room'      => $guest['room_number'],
      'status'    => $guest['status'],
      'check_in'  => $guest['check_in'],
      'check_out' => $guest['check_out'],
    ]
  ]);

} catch (Throwable $e) {
  json_response(500, ['ok'=>false, 'error'=>'server_error']);
}

<?php
require_once __DIR__ . '/../bootstrap.php';

$lang = strtolower($_GET['lang'] ?? $_POST['lang'] ?? 'ar');
$hotel = $_GET['hotel_code'] ?? $_POST['hotel_code'] ??
         $_GET['code'] ?? $_POST['code'] ??
         ($_SERVER['HTTP_X_HOTEL_CODE'] ?? null);

$email = $_GET['email'] ?? $_POST['email'] ?? null;
$phone = $_GET['phone'] ?? $_POST['phone'] ?? null;
$token = $_GET['token'] ?? $_POST['token'] ?? null;

$bookingCode = $_GET['booking_code'] ?? $_POST['booking_code'] ?? null;
$bookingId   = $_GET['id'] ?? $_POST['id'] ?? null;
$reason      = trim($_GET['reason'] ?? $_POST['reason'] ?? '');

$M = [
  'ar' => [
    'missing_hotel'    => 'مطلوب hotel_code',
    'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
    'missing_booking'  => 'مطلوب booking_code أو id',
    'not_found_guest'  => 'لم يتم العثور على النزيل',
    'not_found_booking'=> 'لم يتم العثور على الحجز',
    'invalid_state'    => 'لا يمكن إلغاء هذا الحجز (تم الدخول أو الخروج)',
    'ok'               => 'تم الإلغاء'
  ],
  'en' => [
    'missing_hotel'    => 'hotel_code is required',
    'missing_identity' => 'Email, phone, or token is required',
    'missing_booking'  => 'booking_code or id is required',
    'not_found_guest'  => 'Guest not found',
    'not_found_booking'=> 'Booking not found',
    'invalid_state'    => 'Cancellation not allowed (already checked-in/out)',
    'ok'               => 'Canceled'
  ],
];
$T = $M[$lang] ?? $M['ar'];

try {
  if (!$hotel) { http_response_code(422); echo json_encode(['error'=>$T['missing_hotel']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$email && !$phone && !$token) { http_response_code(422); echo json_encode(['error'=>$T['missing_identity']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$bookingCode && !$bookingId) { http_response_code(422); echo json_encode(['error'=>$T['missing_booking']], JSON_UNESCAPED_UNICODE); exit; }

  // تحقق من النزيل
  $q = "SELECT id, name_en, name_ar, email, phone FROM guests
        WHERE hotel_code = :hotel AND (
          (:email IS NOT NULL AND email = :email) OR
          (:phone IS NOT NULL AND phone = :phone) OR
          (:token IS NOT NULL AND verify_token = :token)
        ) LIMIT 1";
  $st = $pdo->prepare($q);
  $st->execute([':hotel'=>$hotel, ':email'=>$email, ':phone'=>$phone, ':token'=>$token]);
  $guest = $st->fetch();
  if (!$guest) { http_response_code(404); echo json_encode(['error'=>$T['not_found_guest']], JSON_UNESCAPED_UNICODE); exit; }

  // جلب الحجز
  $cond = $bookingCode ? 'booking_code = :b' : 'id = :b';
  $sql  = "SELECT id, booking_code, status, checkin, checkout, total_amount, currency, room_type_en, room_type_ar
           FROM bookings WHERE hotel_code=:hotel AND guest_id=:gid AND $cond LIMIT 1";
  $bst = $pdo->prepare($sql);
  $bst->execute([':hotel'=>$hotel, ':gid'=>$guest['id'], ':b'=>($bookingCode ?: $bookingId)]);
  $bk = $bst->fetch();
  if (!$bk) { http_response_code(404); echo json_encode(['error'=>$T['not_found_booking']], JSON_UNESCAPED_UNICODE); exit; }

  if (in_array($bk['status'], ['checked_in','checked_out'])) {
    http_response_code(422);
    echo json_encode(['error'=>$T['invalid_state']], JSON_UNESCAPED_UNICODE);
    exit;
  }

  // إلغاء
  $ust = $pdo->prepare("UPDATE bookings SET status='canceled', notes_en = CONCAT(COALESCE(notes_en,''), :rn), notes_ar = CONCAT(COALESCE(notes_ar,''), :ra) WHERE id=:id LIMIT 1");
  $rn = $reason ? ("\n[CANCEL REASON] ".$reason) : "";
  $ra = $reason ? ("\n[سبب الإلغاء] ".$reason) : "";
  $ust->execute([':rn'=>$rn, ':ra'=>$ra, ':id'=>$bk['id']]);

  $bk['status'] = 'canceled';
  $bk['room_type'] = ($lang==='en') ? $bk['room_type_en'] : $bk['room_type_ar'];
  unset($bk['room_type_en'],$bk['room_type_ar']);

  echo json_encode([
    'success'=>true,
    'message'=>$T['ok'],
    'booking'=>$bk
  ], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE);
}
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

// قيم قابلة للتعديل (كلها اختيارية)
$checkin  = $_POST['checkin']  ?? $_GET['checkin']  ?? null; // YYYY-MM-DD
$checkout = $_POST['checkout'] ?? $_GET['checkout'] ?? null; // YYYY-MM-DD
$room_en  = $_POST['room_type_en'] ?? $_GET['room_type_en'] ?? null;
$room_ar  = $_POST['room_type_ar'] ?? $_GET['room_type_ar'] ?? null;
$notes_en = $_POST['notes_en'] ?? $_GET['notes_en'] ?? null;
$notes_ar = $_POST['notes_ar'] ?? $_GET['notes_ar'] ?? null;
$total    = $_POST['total_amount'] ?? $_GET['total_amount'] ?? null;
$currency = $_POST['currency'] ?? $_GET['currency'] ?? null;

$M = [
  'ar' => [
    'missing_hotel'    => 'مطلوب hotel_code',
    'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
    'missing_booking'  => 'مطلوب booking_code أو id',
    'not_found_guest'  => 'لم يتم العثور على النزيل',
    'not_found_booking'=> 'لم يتم العثور على الحجز',
    'no_changes'       => 'لا توجد حقول لتعديلها',
    'invalid_date'     => 'صيغة التاريخ غير صحيحة (YYYY-MM-DD)',
    'invalid_range'    => 'نطاق التواريخ غير صحيح (الخروج يجب أن يكون بعد الدخول)',
    'blocked'          => 'لا يمكن تعديل حجز منتهٍ (checked_out)',
    'ok'               => 'تم التحديث'
  ],
  'en' => [
    'missing_hotel'    => 'hotel_code is required',
    'missing_identity' => 'Email, phone, or token is required',
    'missing_booking'  => 'booking_code or id is required',
    'not_found_guest'  => 'Guest not found',
    'not_found_booking'=> 'Booking not found',
    'no_changes'       => 'No fields to update',
    'invalid_date'     => 'Invalid date format (YYYY-MM-DD)',
    'invalid_range'    => 'Invalid date range (checkout must be after checkin)',
    'blocked'          => 'Cannot update a checked-out booking',
    'ok'               => 'Updated'
  ],
];
$T = $M[$lang] ?? $M['ar'];

function is_valid_date($d) { return preg_match('/^\d{4}-\d{2}-\d{2}$/', $d); }

try {
  if (!$hotel) { http_response_code(422); echo json_encode(['error'=>$T['missing_hotel']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$email && !$phone && !$token) { http_response_code(422); echo json_encode(['error'=>$T['missing_identity']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$bookingCode && !$bookingId) { http_response_code(422); echo json_encode(['error'=>$T['missing_booking']], JSON_UNESCAPED_UNICODE); exit; }

  // تحقق من النزيل
  $q = "SELECT id FROM guests WHERE hotel_code=:hotel AND (
          (:email IS NOT NULL AND email=:email) OR
          (:phone IS NOT NULL AND phone=:phone) OR
          (:token IS NOT NULL AND verify_token=:token)
        ) LIMIT 1";
  $st = $pdo->prepare($q);
  $st->execute([':hotel'=>$hotel, ':email'=>$email, ':phone'=>$phone, ':token'=>$token]);
  $guest = $st->fetch();
  if (!$guest) { http_response_code(404); echo json_encode(['error'=>$T['not_found_guest']], JSON_UNESCAPED_UNICODE); exit; }

  // الحجز
  $cond = $bookingCode ? 'booking_code = :b' : 'id = :b';
  $sql  = "SELECT * FROM bookings WHERE hotel_code=:hotel AND guest_id=:gid AND $cond LIMIT 1";
  $bst  = $pdo->prepare($sql);
  $bst->execute([':hotel'=>$hotel, ':gid'=>$guest['id'], ':b'=>($bookingCode ?: $bookingId)]);
  $bk = $bst->fetch();
  if (!$bk) { http_response_code(404); echo json_encode(['error'=>$T['not_found_booking']], JSON_UNESCAPED_UNICODE); exit; }
  if ($bk['status']==='checked_out') { http_response_code(422); echo json_encode(['error'=>$T['blocked']], JSON_UNESCAPED_UNICODE); exit; }

  // صلاحية التواريخ
  if ($checkin && !is_valid_date($checkin)) { http_response_code(422); echo json_encode(['error'=>$T['invalid_date']], JSON_UNESCAPED_UNICODE); exit; }
  if ($checkout && !is_valid_date($checkout)) { http_response_code(422); echo json_encode(['error'=>$T['invalid_date']], JSON_UNESCAPED_UNICODE); exit; }
  if ($checkin && $checkout && $checkout <= $checkin) { http_response_code(422); echo json_encode(['error'=>$T['invalid_range']], JSON_UNESCAPED_UNICODE); exit; }

  // بناء حقول التعديل ديناميكيًا
  $sets = []; $params = [':id'=>$bk['id']];
  if ($checkin  !== null) { $sets[]="checkin=:checkin";   $params[':checkin']=$checkin; }
  if ($checkout !== null) { $sets[]="checkout=:checkout"; $params[':checkout']=$checkout; }
  if ($room_en  !== null) { $sets[]="room_type_en=:ren";  $params[':ren']=$room_en; }
  if ($room_ar  !== null) { $sets[]="room_type_ar=:rar";  $params[':rar']=$room_ar; }
  if ($notes_en !== null) { $sets[]="notes_en=:nen";      $params[':nen']=$notes_en; }
  if ($notes_ar !== null) { $sets[]="notes_ar=:nar";      $params[':nar']=$notes_ar; }
  if ($total    !== null) { $sets[]="total_amount=:tot";  $params[':tot']=(float)$total; }
  if ($currency !== null) { $sets[]="currency=:cur";      $params[':cur']=$currency; }

  if (empty($sets)) { http_response_code(422); echo json_encode(['error'=>$T['no_changes']], JSON_UNESCAPED_UNICODE); exit; }

  $uq = "UPDATE bookings SET ".implode(', ', $sets)." WHERE id=:id LIMIT 1";
  $ust = $pdo->prepare($uq);
  $ust->execute($params);

  // أعد القراءة
  $bst->execute([':hotel'=>$hotel, ':gid'=>$guest['id'], ':b'=>($bookingCode ?: $bookingId)]);
  $bk = $bst->fetch();
  $bk['room_type'] = ($lang==='en') ? $bk['room_type_en'] : $bk['room_type_ar'];
  unset($bk['room_type_en'],$bk['room_type_ar']);

  echo json_encode(['success'=>true, 'message'=>$T['ok'], 'booking'=>$bk], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE);
}

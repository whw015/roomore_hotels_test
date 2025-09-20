<?php
require_once __DIR__ . '/../../_bootstrap.php';

$lang = strtolower($_GET['lang'] ?? $_POST['lang'] ?? 'ar');
$hotel = $_GET['hotel_code'] ?? $_POST['hotel_code'] ?? $_GET['code'] ?? $_POST['code'] ?? ($_SERVER['HTTP_X_HOTEL_CODE'] ?? null);
$email = $_GET['email'] ?? $_POST['email'] ?? null;
$phone = $_GET['phone'] ?? $_POST['phone'] ?? null;
$token = $_GET['token'] ?? $_POST['token'] ?? null;

$bookingCode = $_GET['booking_code'] ?? $_POST['booking_code'] ?? null;
$bookingId   = $_GET['id'] ?? $_POST['id'] ?? null;

$page   = max(1, intval($_GET['page'] ?? $_POST['page'] ?? 1));
$per    = min(100, max(1, intval($_GET['per_page'] ?? $_POST['per_page'] ?? 20)));
$offset = ($page - 1) * $per;

$M = [
  'ar' => [
    'missing_hotel'    => 'مطلوب hotel_code',
    'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
    'missing_booking'  => 'مطلوب booking_code أو id',
    'not_found_guest'  => 'لم يتم العثور على النزيل',
    'not_found_booking'=> 'لم يتم العثور على الحجز',
    'ok'               => 'نجاح'
  ],
  'en' => [
    'missing_hotel'    => 'hotel_code is required',
    'missing_identity' => 'Email, phone, or token is required',
    'missing_booking'  => 'booking_code or id is required',
    'not_found_guest'  => 'Guest not found',
    'not_found_booking'=> 'Booking not found',
    'ok'               => 'OK'
  ],
];
$T = $M[$lang] ?? $M['ar'];

try {
  if (!$hotel) { http_response_code(422); echo json_encode(['error'=>$T['missing_hotel']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$email && !$phone && !$token) { http_response_code(422); echo json_encode(['error'=>$T['missing_identity']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$bookingCode && !$bookingId) { http_response_code(422); echo json_encode(['error'=>$T['missing_booking']], JSON_UNESCAPED_UNICODE); exit; }

  $st = $pdo->prepare("SELECT id, name_en, name_ar, email, phone FROM guests WHERE hotel_code=:hotel AND ((:email IS NOT NULL AND email=:email) OR (:phone IS NOT NULL AND phone=:phone) OR (:token IS NOT NULL AND verify_token=:token)) LIMIT 1");
  $st->execute([':hotel'=>$hotel, ':email'=>$email, ':phone'=>$phone, ':token'=>$token]);
  $guest = $st->fetch();
  if (!$guest) { http_response_code(404); echo json_encode(['error'=>$T['not_found_guest']], JSON_UNESCAPED_UNICODE); exit; }

  $cond = $bookingCode ? 'booking_code = :b' : 'id = :b';
  $bst = $pdo->prepare("SELECT id, booking_code FROM bookings WHERE hotel_code=:hotel AND guest_id=:gid AND $cond LIMIT 1");
  $bst->execute([':hotel'=>$hotel, ':gid'=>$guest['id'], ':b'=>($bookingCode ?: $bookingId)]);
  $bk = $bst->fetch();
  if (!$bk) { http_response_code(404); echo json_encode(['error'=>$T['not_found_booking']], JSON_UNESCAPED_UNICODE); exit; }

  $cst = $pdo->prepare("SELECT COUNT(*) FROM invoices WHERE hotel_code=:hotel AND booking_id=:bid");
  $cst->execute([':hotel'=>$hotel, ':bid'=>$bk['id']]);
  $total = (int)$cst->fetchColumn();

  $lim = (int)$per; $off=(int)$offset;
  $ist = $pdo->prepare("SELECT id, number, status, currency, subtotal, tax_amount, total, created_at
                        FROM invoices WHERE hotel_code=:hotel AND booking_id=:bid
                        ORDER BY created_at DESC
                        LIMIT $lim OFFSET $off");
  $ist->execute([':hotel'=>$hotel, ':bid'=>$bk['id']]);
  $rows = $ist->fetchAll();

  echo json_encode([
    'success'=>true,
    'message'=>$T['ok'],
    'guest'=>[
      'id'=>(int)$guest['id'],
      'name'=>($lang==='en'?$guest['name_en']:$guest['name_ar']),
      'email'=>$guest['email'],
      'phone'=>$guest['phone'],
    ],
    'booking'=>[ 'id'=>(int)$bk['id'], 'booking_code'=>$bk['booking_code'] ],
    'pagination'=>[ 'page'=>$page, 'per_page'=>$per, 'total'=>$total, 'total_pages'=>(int)ceil($total/max(1,$per)) ],
    'invoices'=>$rows
  ], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE);
}
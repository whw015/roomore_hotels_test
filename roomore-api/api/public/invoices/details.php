<?php
require_once __DIR__ . '/../../_bootstrap.php';

$lang = strtolower($_GET['lang'] ?? $_POST['lang'] ?? 'ar');
$hotel = $_GET['hotel_code'] ?? $_POST['hotel_code'] ?? $_GET['code'] ?? $_POST['code'] ?? ($_SERVER['HTTP_X_HOTEL_CODE'] ?? null);
$email = $_GET['email'] ?? $_POST['email'] ?? null;
$phone = $_GET['phone'] ?? $_POST['phone'] ?? null;
$token = $_GET['token'] ?? $_POST['token'] ?? null;

$invoiceId = $_GET['invoice_id'] ?? $_POST['invoice_id'] ?? null;
$number    = $_GET['number'] ?? $_POST['number'] ?? null;

$M = [
  'ar' => [
    'missing_hotel'    => 'مطلوب hotel_code',
    'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
    'missing_invoice'  => 'مطلوب invoice_id أو number',
    'not_found_guest'  => 'لم يتم العثور على النزيل',
    'not_found_invoice'=> 'لم يتم العثور على الفاتورة',
    'ok'               => 'نجاح'
  ],
  'en' => [
    'missing_hotel'    => 'hotel_code is required',
    'missing_identity' => 'Email, phone, or token is required',
    'missing_invoice'  => 'invoice_id or number is required',
    'not_found_guest'  => 'Guest not found',
    'not_found_invoice'=> 'Invoice not found',
    'ok'               => 'OK'
  ],
];
$T = $M[$lang] ?? $M['ar'];

try {
  if (!$hotel) { http_response_code(422); echo json_encode(['error'=>$T['missing_hotel']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$email && !$phone && !$token) { http_response_code(422); echo json_encode(['error'=>$T['missing_identity']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$invoiceId && !$number) { http_response_code(422); echo json_encode(['error'=>$T['missing_invoice']], JSON_UNESCAPED_UNICODE); exit; }

  $st = $pdo->prepare("SELECT id FROM guests WHERE hotel_code=:hotel AND ((:email IS NOT NULL AND email=:email) OR (:phone IS NOT NULL AND phone=:phone) OR (:token IS NOT NULL AND verify_token=:token)) LIMIT 1");
  $st->execute([':hotel'=>$hotel, ':email'=>$email, ':phone'=>$phone, ':token'=>$token]);
  $guest = $st->fetch();
  if (!$guest) { http_response_code(404); echo json_encode(['error'=>$T['not_found_guest']], JSON_UNESCAPED_UNICODE); exit; }

  $cond = $invoiceId ? 'i.id = :x' : 'i.number = :x';
  $sql = "SELECT i.*, b.booking_code FROM invoices i
          INNER JOIN bookings b ON b.id = i.booking_id
          WHERE i.hotel_code=:hotel AND b.guest_id=:gid AND $cond
          LIMIT 1";
  $it = $pdo->prepare($sql);
  $it->execute([':hotel'=>$hotel, ':gid'=>$guest['id'], ':x'=>($invoiceId ?: $number)]);
  $inv = $it->fetch();
  if (!$inv) { http_response_code(404); echo json_encode(['error'=>$T['not_found_invoice']], JSON_UNESCAPED_UNICODE); exit; }

  $items = $pdo->prepare("SELECT id, description_en, description_ar, qty, unit_price, total, sort_order FROM invoice_items WHERE invoice_id=:iid ORDER BY sort_order ASC, id ASC");
  $items->execute([':iid'=>$inv['id']]);
  $inv_items = $items->fetchAll();

  echo json_encode(['success'=>true, 'message'=>$T['ok'], 'invoice'=>$inv, 'items'=>$inv_items], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE);
}
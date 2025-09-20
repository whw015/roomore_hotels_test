<?php
require_once __DIR__ . '/../bootstrap.php';
$lang = strtolower($_GET['lang'] ?? $_POST['lang'] ?? 'ar');
$hotel = $_GET['hotel_code'] ?? $_POST['hotel_code'] ?? $_GET['code'] ?? $_POST['code'] ?? ($_SERVER['HTTP_X_HOTEL_CODE'] ?? null);
$email = $_GET['email'] ?? $_POST['email'] ?? null;
$phone = $_GET['phone'] ?? $_POST['phone'] ?? null;
$token = $_GET['token'] ?? $_POST['token'] ?? null;
$bookingCode = $_GET['booking_code'] ?? $_POST['booking_code'] ?? null;
$bookingId   = $_GET['id'] ?? $_POST['id'] ?? null;

$raw = file_get_contents('php://input');
$body = json_decode($raw, true);
if (!is_array($body)) $body = [];
$items = $body['items'] ?? null;
$notes_en = $body['notes_en'] ?? ($_POST['notes_en'] ?? null);
$notes_ar = $body['notes_ar'] ?? ($_POST['notes_ar'] ?? null);
$tax_percent = isset($body['tax_percent']) ? (float)$body['tax_percent'] : (isset($_POST['tax_percent']) ? (float)$_POST['tax_percent'] : 0.0);

$M = [
  'ar' => [
    'missing_hotel'    => 'مطلوب hotel_code',
    'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
    'missing_booking'  => 'مطلوب booking_code أو id',
    'not_found_guest'  => 'لم يتم العثور على النزيل',
    'not_found_booking'=> 'لم يتم العثور على الحجز',
    'ok'               => 'تم إنشاء الفاتورة'
  ],
  'en' => [
    'missing_hotel'    => 'hotel_code is required',
    'missing_identity' => 'Email, phone, or token is required',
    'missing_booking'  => 'booking_code or id is required',
    'not_found_guest'  => 'Guest not found',
    'not_found_booking'=> 'Booking not found',
    'ok'               => 'Invoice created'
  ],
];
$T = $M[$lang] ?? $M['ar'];

try {
  if (!$hotel) { http_response_code(422); echo json_encode(['error'=>$T['missing_hotel']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$email && !$phone && !$token) { http_response_code(422); echo json_encode(['error'=>$T['missing_identity']], JSON_UNESCAPED_UNICODE); exit; }
  if (!$bookingCode && !$bookingId) { http_response_code(422); echo json_encode(['error'=>$T['missing_booking']], JSON_UNESCAPED_UNICODE); exit; }

  // guest
  $st = $pdo->prepare("SELECT id FROM guests WHERE hotel_code=:hotel AND ((:email IS NOT NULL AND email=:email) OR (:phone IS NOT NULL AND phone=:phone) OR (:token IS NOT NULL AND verify_token=:token)) LIMIT 1");
  $st->execute([':hotel'=>$hotel, ':email'=>$email, ':phone'=>$phone, ':token'=>$token]);
  $guest = $st->fetch();
  if (!$guest) { http_response_code(404); echo json_encode(['error'=>$T['not_found_guest']], JSON_UNESCAPED_UNICODE); exit; }

  // booking
  $cond = $bookingCode ? 'booking_code = :b' : 'id = :b';
  $bst  = $pdo->prepare("SELECT id, booking_code, total_amount, currency FROM bookings WHERE hotel_code=:hotel AND guest_id=:gid AND $cond LIMIT 1");
  $bst->execute([':hotel'=>$hotel, ':gid'=>$guest['id'], ':b'=>($bookingCode ?: $bookingId)]);
  $bk = $bst->fetch();
  if (!$bk) { http_response_code(404); echo json_encode(['error'=>$T['not_found_booking']], JSON_UNESCAPED_UNICODE); exit; }

  // prepare totals
  $currency = $bk['currency'] ?: 'SAR';
  $subtotal = 0.0;
  $preparedItems = [];

  if (is_array($items) && count($items)>0) {
    foreach ($items as $i => $it) {
      $qty = (float)($it['qty'] ?? 1);
      $price = (float)($it['unit_price'] ?? 0);
      $line = round($qty * $price, 2);
      $subtotal += $line;
      $preparedItems[] = [
        'description_en' => $it['description_en'] ?? null,
        'description_ar' => $it['description_ar'] ?? null,
        'qty' => $qty,
        'unit_price' => $price,
        'total' => $line,
        'sort_order' => $i
      ];
    }
  } else {
    // fallback: single line from booking amount
    $line = (float)($bk['total_amount'] ?? 0);
    $subtotal = $line;
    $preparedItems[] = [
      'description_en' => 'Booking charges',
      'description_ar' => 'رسوم الحجز',
      'qty' => 1,
      'unit_price' => $line,
      'total' => $line,
      'sort_order' => 0
    ];
  }

  $tax_amount = round(($tax_percent/100.0) * $subtotal, 2);
  $total = round($subtotal + $tax_amount, 2);

  // generate invoice number simple
  $seq = (int)$pdo->query("SELECT IFNULL(MAX(id),0)+1 FROM invoices")->fetchColumn();
  $number = sprintf("INV-%s-%04d", date('Y'), $seq);

  // insert invoice
  $ist = $pdo->prepare("INSERT INTO invoices (hotel_code, booking_id, number, status, currency, subtotal, tax_amount, total, notes_en, notes_ar)
                        VALUES (:hotel, :bid, :num, 'issued', :cur, :sub, :tax, :tot, :nen, :nar)");
  $ist->execute([
    ':hotel'=>$hotel, ':bid'=>$bk['id'], ':num'=>$number, ':cur'=>$currency,
    ':sub'=>$subtotal, ':tax'=>$tax_amount, ':tot'=>$total,
    ':nen'=>$notes_en, ':nar'=>$notes_ar
  ]);
  $invoice_id = (int)$pdo->lastInsertId();

  // insert items
  $iit = $pdo->prepare("INSERT INTO invoice_items (invoice_id, description_en, description_ar, qty, unit_price, total, sort_order)
                        VALUES (:iid, :den, :dar, :q, :up, :t, :s)");
  foreach ($preparedItems as $pi) {
    $iit->execute([':iid'=>$invoice_id, ':den'=>$pi['description_en'], ':dar'=>$pi['description_ar'], ':q'=>$pi['qty'], ':up'=>$pi['unit_price'], ':t'=>$pi['total'], ':s'=>$pi['sort_order']]);
  }

  echo json_encode([
    'success'=>true,
    'message'=>$T['ok'],
    'invoice'=>[
      'id'=>$invoice_id,
      'number'=>$number,
      'currency'=>$currency,
      'subtotal'=>$subtotal,
      'tax_amount'=>$tax_amount,
      'total'=>$total
    ]
  ], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE);
}
<?php
require_once __DIR__ . '/../../_bootstrap.php';

$lang = strtolower($_GET['lang'] ?? $_POST['lang'] ?? 'ar');
$hotel = $_GET['hotel_code'] ?? $_POST['hotel_code'] ??
         $_GET['code'] ?? $_POST['code'] ??
         ($_SERVER['HTTP_X_HOTEL_CODE'] ?? null);

$email = $_GET['email'] ?? $_POST['email'] ?? null;
$phone = $_GET['phone'] ?? $_POST['phone'] ?? null;
$token = $_GET['token'] ?? $_POST['token'] ?? null;

$status = $_GET['status'] ?? $_POST['status'] ?? null;
$page   = max(1, intval($_GET['page'] ?? $_POST['page'] ?? 1));
$per    = min(100, max(1, intval($_GET['per_page'] ?? $_POST['per_page'] ?? 20)));
$offset = ($page - 1) * $per;

$M = [
  'ar' => [
    'missing_hotel'    => 'مطلوب hotel_code',
    'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
    'not_found_guest'  => 'لم يتم العثور على النزيل',
    'ok'               => 'نجاح'
  ],
  'en' => [
    'missing_hotel'    => 'hotel_code is required',
    'missing_identity' => 'Email, phone, or token is required',
    'not_found_guest'  => 'Guest not found',
    'ok'               => 'OK'
  ],
];
$T = $M[$lang] ?? $M['ar'];

try {
  if (!$hotel) {
    http_response_code(422);
    echo json_encode(['error' => $T['missing_hotel']], JSON_UNESCAPED_UNICODE);
    exit;
  }
  if (!$email && !$phone && !$token) {
    http_response_code(422);
    echo json_encode(['error' => $T['missing_identity']], JSON_UNESCAPED_UNICODE);
    exit;
  }

  // ابحث عن النزيل ضمن نفس الفندق بالهوية المتسامحة (email/phone/token)
  $q = "SELECT id, name_en, name_ar, email, phone
        FROM guests
        WHERE hotel_code = :hotel AND (
          (:email IS NOT NULL AND email = :email) OR
          (:phone IS NOT NULL AND phone = :phone) OR
          (:token IS NOT NULL AND verify_token = :token)
        )
        LIMIT 1";
  $st = $pdo->prepare($q);
  $st->execute([
    ':hotel' => $hotel,
    ':email' => $email,
    ':phone' => $phone,
    ':token' => $token,
  ]);
  $guest = $st->fetch(PDO::FETCH_ASSOC);

  if (!$guest) {
    http_response_code(404);
    echo json_encode(['error' => $T['not_found_guest']], JSON_UNESCAPED_UNICODE);
    exit;
  }

  // فلترة الحالة (اختياري)
  $statusSql = '';
  if ($status) {
    $statusSql = " AND status = :status ";
  }

  // --------- العد (مصفوفة خاصة بدون :lim و :off) ---------
  $countSql = "SELECT COUNT(*)
               FROM bookings
               WHERE hotel_code=:hotel AND guest_id=:gid $statusSql";
  $countParams = [
    ':hotel' => $hotel,
    ':gid'   => $guest['id'],
  ];
  if ($status) { $countParams[':status'] = $status; }

  $cst = $pdo->prepare($countSql);
  $cst->execute($countParams);
  $total = (int)$cst->fetchColumn();

  // --------- الجلب (مصفوفة خاصة + LIMIT/OFFSET أعداد صحيحة مباشرة) ---------
  $lim = (int)$per;
  $off = (int)$offset;

  $sql = "SELECT id, booking_code, checkin, checkout, status, total_amount, currency,
                 room_type_en, room_type_ar, created_at
          FROM bookings
          WHERE hotel_code=:hotel AND guest_id=:gid $statusSql
          ORDER BY checkin DESC
          LIMIT $lim OFFSET $off";

  $bst = $pdo->prepare($sql);
  $bst->bindValue(':hotel', $hotel);
  $bst->bindValue(':gid', (int)$guest['id'], PDO::PARAM_INT);
  if ($status) $bst->bindValue(':status', $status);
  $bst->execute();
  $rows = $bst->fetchAll(PDO::FETCH_ASSOC);

  // الحقول المعتمدة على اللغة
  foreach ($rows as &$r) {
    $r['room_type'] = ($lang === 'en') ? ($r['room_type_en'] ?? null) : ($r['room_type_ar'] ?? null);
    unset($r['room_type_en'], $r['room_type_ar']);
  }
  unset($r); // فك المرجع

  $resp = [
    'success' => true,
    'message' => $T['ok'],
    'guest' => [
      'id'    => (int)$guest['id'],
      'name'  => ($lang === 'en') ? $guest['name_en'] : $guest['name_ar'],
      'email' => $guest['email'],
      'phone' => $guest['phone'],
    ],
    'pagination' => [
      'page'        => $page,
      'per_page'    => $per,
      'total'       => $total,
      'total_pages' => (int)ceil($total / max(1, $per)),
    ],
    'bookings' => $rows,
  ];

  echo json_encode($resp, JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}

<?php
require_once __DIR__ . '/../bootstrap.php';
$body = get_json_body();
$code = trim((string)($body['code'] ?? ''));
if ($code === '') json_response(422, false, 'code is required');

try {
  $pdo = db();
  $stmt = $pdo->prepare('SELECT id, code, name_en, name_ar, status FROM hotels WHERE code = ? LIMIT 1');
  $stmt->execute([$code]);
  $row = $stmt->fetch();
  if (!$row) json_response(404, false, 'hotel_not_found');

  $data = [
    'hotelId'   => $row['code'],                // يطابق Firestore hotelId (مثلاً RMR001)
    'hotelName' => ['en'=>$row['name_en'], 'ar'=>$row['name_ar']],
    'status'    => $row['status'] ?? 'active',
  ];
  json_response(200, true, null, $data);
} catch (Throwable $e) {
  json_response(500, false, 'server_error');
}

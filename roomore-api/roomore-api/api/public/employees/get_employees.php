<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../_bootstrap.php';

function input_param(string $key): ?string {
  if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    return isset($_GET[$key]) ? trim((string)$_GET[$key]) : null;
  }
  $body = json_input();
  if (isset($body[$key])) return trim((string)$body[$key]);
  if (isset($_POST[$key])) return trim((string)$_POST[$key]);
  return null;
}

function resolve_hotel_id(PDO $pdo, ?string $hotelIdOrCode): ?int {
  if (!$hotelIdOrCode || $hotelIdOrCode === '') return null;
  if (ctype_digit($hotelIdOrCode)) return (int)$hotelIdOrCode;

  $needle = strtolower(preg_replace('/\s+/', '', $hotelIdOrCode));
  $st = $pdo->prepare('SELECT id FROM hotels WHERE LOWER(COALESCE(code,""))=:q OR LOWER(COALESCE(slug,""))=:q LIMIT 1');
  $st->execute([':q' => $needle]);
  $row = $st->fetch(PDO::FETCH_ASSOC);
  return $row ? (int)$row['id'] : null;
}

try {
  global $pdo;
  $hotelArg = input_param('hotel_id') ?? input_param('hotelId') ?? input_param('code');
  $hotelId  = resolve_hotel_id($pdo, $hotelArg);

  if (!$hotelId) {
    json_response(200, ['ok'=>false, 'error'=>'hotel_not_found', 'employees'=>[]]);
  }

  $sql = 'SELECT id, hotel_id, name, email, phone, status FROM hotel_employees WHERE hotel_id = :hid ORDER BY id DESC';
  $st  = $pdo->prepare($sql);
  $st->execute([':hid' => $hotelId]);

  $out = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $out[] = [
      'id'       => (string)$r['id'],
      'hotel_id' => (string)$r['hotel_id'],
      'name'     => (string)($r['name'] ?? ''),
      'email'    => (string)($r['email'] ?? ''),
      'phone'    => (string)($r['phone'] ?? ''),
      'status'   => (string)($r['status'] ?? ''),
    ];
  }

  json_response(200, ['ok'=>true, 'employees'=>$out]);

} catch (Throwable $e) {
  json_response(500, ['ok'=>false,'error'=>'server_error']);
}

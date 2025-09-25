<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../_bootstrap.php'; // provides $pdo, json_input(), json_response()

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
    json_response(200, ['ok' => false, 'error' => 'hotel_not_found']);
  }

  $name   = input_param('name') ?? input_param('fullName') ?? input_param('full_name') ?? '';
  $email  = input_param('email') ?? '';
  $phone  = input_param('phone') ?? '';
  $status = input_param('is_active');
  $status = ($status === '1' || $status === 'true' || $status === 'on' || $status === 'yes' || $status === 'active' || $status === 'True' || $status === 'TRUE') ? 'active' : 'inactive';

  if ($name === '') {
    json_response(200, ['ok' => false, 'error' => 'missing_name']);
  }

  $sql = 'INSERT INTO hotel_employees (hotel_id, name, email, phone, status) VALUES (:hid, :n, :e, :p, :s)';
  $st  = $pdo->prepare($sql);
  $st->execute([
    ':hid' => $hotelId,
    ':n'   => $name,
    ':e'   => $email,
    ':p'   => $phone,
    ':s'   => $status,
  ]);

  $id = (int)$pdo->lastInsertId();
  json_response(200, [
    'ok' => true,
    'employee' => [
      'id'       => (string)$id,
      'hotel_id' => (string)$hotelId,
      'name'     => $name,
      'email'    => $email,
      'phone'    => $phone,
      'status'   => $status,
    ],
  ]);

} catch (Throwable $e) {
  json_response(500, ['ok' => false, 'error' => 'server_error']);
}


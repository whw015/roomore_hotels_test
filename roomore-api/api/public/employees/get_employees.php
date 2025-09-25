<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../_bootstrap.php';

function column_exists(PDO $pdo, string $table, string $column): bool {
  $sql = 'SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = :t AND COLUMN_NAME = :c
          LIMIT 1';
  $st = $pdo->prepare($sql);
  $st->execute([':t' => $table, ':c' => $column]);
  return (bool)$st->fetchColumn();
}

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

  $hasAvatar = column_exists($pdo, 'hotel_employees', 'avatar_url');
  $hasGender = column_exists($pdo, 'hotel_employees', 'gender');
  $hasNationality = column_exists($pdo, 'hotel_employees', 'nationality');
  $hasDob = column_exists($pdo, 'hotel_employees', 'dob');
  $hasIdNumber = column_exists($pdo, 'hotel_employees', 'id_number');
  $hasJobTitle = column_exists($pdo, 'hotel_employees', 'job_title');
  $hasEmployeeId = column_exists($pdo, 'hotel_employees', 'employee_id');
  $hasWorkgroup = column_exists($pdo, 'hotel_employees', 'workgroup');

  $cols = ['id','hotel_id','name','email','phone','status'];
  if ($hasAvatar) $cols[]='avatar_url';
  if ($hasGender) $cols[]='gender';
  if ($hasNationality) $cols[]='nationality';
  if ($hasDob) $cols[]='dob';
  if ($hasIdNumber) $cols[]='id_number';
  if ($hasJobTitle) $cols[]='job_title';
  if ($hasEmployeeId) $cols[]='employee_id';
  if ($hasWorkgroup) $cols[]='workgroup';

  $sql = 'SELECT '.implode(',', $cols).' FROM hotel_employees WHERE hotel_id = :hid ORDER BY id DESC';
  $st  = $pdo->prepare($sql);
  $st->execute([':hid' => $hotelId]);

  $out = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $row = [
      'id'         => (string)$r['id'],
      'hotel_id'   => (string)$r['hotel_id'],
      'name'       => (string)($r['name'] ?? ''),
      'email'      => (string)($r['email'] ?? ''),
      'phone'      => (string)($r['phone'] ?? ''),
      'status'     => (string)($r['status'] ?? ''),
    ];
    $row['avatar_url'] = $hasAvatar ? (string)($r['avatar_url'] ?? '') : '';
    if ($hasGender)      $row['gender']      = (string)($r['gender'] ?? '');
    if ($hasNationality) $row['nationality'] = (string)($r['nationality'] ?? '');
    if ($hasDob)         $row['dob']         = (string)($r['dob'] ?? '');
    if ($hasIdNumber)    $row['id_number']   = (string)($r['id_number'] ?? '');
    if ($hasJobTitle)    $row['job_title']   = (string)($r['job_title'] ?? '');
    if ($hasEmployeeId)  $row['employee_id'] = (string)($r['employee_id'] ?? '');
    if ($hasWorkgroup)   $row['workgroup']   = (string)($r['workgroup'] ?? '');
    $out[] = $row;
  }

  json_response(200, ['ok'=>true, 'employees'=>$out]);

} catch (Throwable $e) {
  json_response(500, ['ok'=>false,'error'=>'server_error']);
}

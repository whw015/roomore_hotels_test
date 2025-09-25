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
    json_response(200, ['ok' => false, 'error' => 'hotel_not_found']);
  }

  $name     = input_param('name') ?? input_param('fullName') ?? input_param('full_name') ?? '';
  $email    = input_param('email') ?? '';
  $phone    = input_param('phone') ?? '';
  $avatar   = input_param('avatar_url');
  $status   = input_param('is_active');
  $status   = ($status === '1' || $status === 'true' || $status === 'on' || $status === 'yes' || $status === 'active' || $status === 'True' || $status === 'TRUE') ? 'active' : 'inactive';
  $gender   = input_param('gender');
  $nationality = input_param('nationality');
  $dobIn    = input_param('dob') ?? input_param('birthDate') ?? input_param('birthdate');
  $idNumber = input_param('id_number') ?? input_param('idNumber');
  $jobTitle = input_param('job_title') ?? input_param('title');
  $employeeCode = input_param('employee_id') ?? input_param('employeeNo') ?? input_param('employee_no');
  $workgroup = input_param('workgroup');

  if ($name === '') {
    json_response(200, ['ok' => false, 'error' => 'missing_name']);
  }

  $hasAvatar = column_exists($pdo, 'hotel_employees', 'avatar_url');
  $hasGender = column_exists($pdo, 'hotel_employees', 'gender');
  $hasNationality = column_exists($pdo, 'hotel_employees', 'nationality');
  $hasDob = column_exists($pdo, 'hotel_employees', 'dob');
  $hasIdNumber = column_exists($pdo, 'hotel_employees', 'id_number');
  $hasJobTitle = column_exists($pdo, 'hotel_employees', 'job_title');
  $hasEmployeeId = column_exists($pdo, 'hotel_employees', 'employee_id');
  $hasWorkgroup = column_exists($pdo, 'hotel_employees', 'workgroup');

  $cols = ['hotel_id','name','email','phone','status'];
  $params = [':hid'=>$hotelId, ':n'=>$name, ':e'=>$email, ':p'=>$phone, ':s'=>$status];
  if ($hasAvatar) { $cols[]='avatar_url'; $params[':a']=$avatar; }
  if ($hasGender) { $cols[]='gender'; $params[':g']=$gender; }
  if ($hasNationality) { $cols[]='nationality'; $params[':nat']=$nationality; }
  if ($hasDob) { $cols[]='dob'; $params[':dob'] = $dobIn ? substr($dobIn,0,10) : null; }
  if ($hasIdNumber) { $cols[]='id_number'; $params[':idn']=$idNumber; }
  if ($hasJobTitle) { $cols[]='job_title'; $params[':jt']=$jobTitle; }
  if ($hasEmployeeId) { $cols[]='employee_id'; $params[':eid']=$employeeCode; }
  if ($hasWorkgroup) { $cols[]='workgroup'; $params[':wg']=$workgroup; }

  $placeholders = [];
  foreach ($cols as $c) { $placeholders[] = ':' . ( $c==='hotel_id' ? 'hid' : ($c==='name'?'n': ($c==='email'?'e': ($c==='phone'?'p': ($c==='status'?'s': ($c==='avatar_url'?'a': ($c==='gender'?'g': ($c==='nationality'?'nat': ($c==='dob'?'dob': ($c==='id_number'?'idn': ($c==='job_title'?'jt': ($c==='employee_id'?'eid':'wg')))))))))))); }
  $sql = 'INSERT INTO hotel_employees (' . implode(',',$cols) . ') VALUES (' . implode(',',$placeholders) . ')';
  $st  = $pdo->prepare($sql);
  $st->execute($params);

  $id = (int)$pdo->lastInsertId();
  json_response(200, [
    'ok' => true,
    'employee' => [
      'id'         => (string)$id,
      'hotel_id'   => (string)$hotelId,
      'name'       => $name,
      'email'      => $email,
      'phone'      => $phone,
      'status'     => $status,
      'avatar_url' => $hasAvatar ? (string)($avatar ?? '') : '',
      'gender'     => $hasGender ? (string)($gender ?? '') : '',
      'nationality'=> $hasNationality ? (string)($nationality ?? '') : '',
      'dob'        => $hasDob ? (string)(($dobIn ? substr($dobIn,0,10) : '')) : '',
      'id_number'  => $hasIdNumber ? (string)($idNumber ?? '') : '',
      'job_title'  => $hasJobTitle ? (string)($jobTitle ?? '') : '',
      'employee_id'=> $hasEmployeeId ? (string)($employeeCode ?? '') : '',
      'workgroup'  => $hasWorkgroup ? (string)($workgroup ?? '') : '',
    ],
  ]);

} catch (Throwable $e) {
  json_response(500, ['ok' => false, 'error' => 'server_error']);
}

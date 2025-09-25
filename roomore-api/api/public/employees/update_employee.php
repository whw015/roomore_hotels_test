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

function column_exists(PDO $pdo, string $table, string $column): bool {
  $sql = 'SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = :t AND COLUMN_NAME = :c
          LIMIT 1';
  $st = $pdo->prepare($sql);
  $st->execute([':t' => $table, ':c' => $column]);
  return (bool)$st->fetchColumn();
}

try {
  global $pdo;
  $id = input_param('id');
  if (!$id || !ctype_digit($id)) {
    json_response(200, ['ok'=>false, 'error'=>'invalid_id']);
  }

  $name     = input_param('name') ?? input_param('fullName') ?? input_param('full_name');
  $email    = input_param('email');
  $phone    = input_param('phone');
  $statusIn = input_param('is_active');
  $status   = ($statusIn === '1' || $statusIn === 'true' || $statusIn === 'active') ? 'active' : 'inactive';
  $avatar   = input_param('avatar_url');
  $gender   = input_param('gender');
  $nationality = input_param('nationality');
  $dobIn    = input_param('dob') ?? input_param('birthDate') ?? input_param('birthdate');
  $idNumber = input_param('id_number') ?? input_param('idNumber');
  $jobTitle = input_param('job_title') ?? input_param('title');
  $employeeCode = input_param('employee_id') ?? input_param('employeeNo') ?? input_param('employee_no');
  $workgroup = input_param('workgroup');

  $hasAvatar = column_exists($pdo, 'hotel_employees', 'avatar_url');
  $hasGender = column_exists($pdo, 'hotel_employees', 'gender');
  $hasNationality = column_exists($pdo, 'hotel_employees', 'nationality');
  $hasDob = column_exists($pdo, 'hotel_employees', 'dob');
  $hasIdNumber = column_exists($pdo, 'hotel_employees', 'id_number');
  $hasJobTitle = column_exists($pdo, 'hotel_employees', 'job_title');
  $hasEmployeeId = column_exists($pdo, 'hotel_employees', 'employee_id');
  $hasWorkgroup = column_exists($pdo, 'hotel_employees', 'workgroup');

  $fields = [];
  $params = [':id' => (int)$id];
  if ($name !== null) { $fields[] = 'name = :n'; $params[':n'] = $name; }
  if ($email !== null) { $fields[] = 'email = :e'; $params[':e'] = $email; }
  if ($phone !== null) { $fields[] = 'phone = :p'; $params[':p'] = $phone; }
  if ($statusIn !== null) { $fields[] = 'status = :s'; $params[':s'] = $status; }
  if ($hasAvatar && $avatar !== null) { $fields[] = 'avatar_url = :a'; $params[':a'] = $avatar; }
  if ($hasGender && $gender !== null) { $fields[] = 'gender = :g'; $params[':g'] = $gender; }
  if ($hasNationality && $nationality !== null) { $fields[] = 'nationality = :nat'; $params[':nat'] = $nationality; }
  if ($hasDob && $dobIn !== null) {
    $dob = substr($dobIn, 0, 10);
    $fields[] = 'dob = :dob'; $params[':dob'] = $dob;
  }
  if ($hasIdNumber && $idNumber !== null) { $fields[] = 'id_number = :idn'; $params[':idn'] = $idNumber; }
  if ($hasJobTitle && $jobTitle !== null) { $fields[] = 'job_title = :jt'; $params[':jt'] = $jobTitle; }
  if ($hasEmployeeId && $employeeCode !== null) { $fields[] = 'employee_id = :eid'; $params[':eid'] = $employeeCode; }
  if ($hasWorkgroup && $workgroup !== null) { $fields[] = 'workgroup = :wg'; $params[':wg'] = $workgroup; }

  if (empty($fields)) {
    json_response(200, ['ok'=>true, 'employee'=>['id'=>$id]]);
  }

  $sql = 'UPDATE hotel_employees SET '.implode(', ', $fields).' WHERE id = :id LIMIT 1';
  $st = $pdo->prepare($sql);
  $st->execute($params);

  $row = ['id'=>(string)$id];
  if ($name !== null) $row['name']=$name;
  if ($email !== null) $row['email']=$email;
  if ($phone !== null) $row['phone']=$phone;
  if ($statusIn !== null) $row['status']=$status;
  if ($hasAvatar && $avatar !== null) $row['avatar_url']=$avatar;
  if ($hasGender && $gender !== null) $row['gender']=$gender;
  if ($hasNationality && $nationality !== null) $row['nationality']=$nationality;
  if ($hasDob && $dobIn !== null) $row['dob']=substr($dobIn,0,10);
  if ($hasIdNumber && $idNumber !== null) $row['id_number']=$idNumber;
  if ($hasJobTitle && $jobTitle !== null) $row['job_title']=$jobTitle;
  if ($hasEmployeeId && $employeeCode !== null) $row['employee_id']=$employeeCode;
  if ($hasWorkgroup && $workgroup !== null) $row['workgroup']=$workgroup;

  json_response(200, ['ok'=>true, 'employee'=>$row]);
} catch (Throwable $e) {
  json_response(500, ['ok'=>false, 'error'=>'server_error']);
}

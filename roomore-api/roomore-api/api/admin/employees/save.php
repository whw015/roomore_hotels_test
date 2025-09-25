<?php
declare(strict_types=1);

require_once __DIR__ . '/../_bootstrap.php';
header('Content-Type: application/json; charset=utf-8');

try {
  $db = db();
  if (!$db) json_error('db_unavailable');

  $b = get_json_body();
  $code = strtolower(trim($b['code'] ?? ''));
  $id   = isset($b['id']) ? (int)$b['id'] : null;

  $name = trim((string)($b['name'] ?? ''));
  $email = trim((string)($b['email'] ?? ''));
  $phone = trim((string)($b['phone'] ?? ''));
  $status = in_array(($b['status'] ?? 'active'), ['active','inactive'], true) ? $b['status'] : 'active';
  $groupIds = is_array($b['groupIds'] ?? null) ? array_map('intval', $b['groupIds']) : [];

  if ($code==='' || $name==='') json_fail('invalid_input');

  $st = $db->prepare("SELECT id FROM hotels WHERE LOWER(code)=LOWER(?) LIMIT 1");
  $st->execute([$code]);
  $hotel = $st->fetch(PDO::FETCH_ASSOC);
  if (!$hotel) json_fail('hotel_not_found');
  $hotelId = (int)$hotel['id'];

  if ($id) {
    $sql="UPDATE hotel_employees
            SET name=:name, email=NULLIF(:email,''), phone=NULLIF(:phone,''), status=:status
          WHERE id=:id AND hotel_id=:hid";
    $st=$db->prepare($sql);
    $ok=$st->execute([':name'=>$name, ':email'=>$email, ':phone'=>$phone, ':status'=>$status, ':id'=>$id, ':hid'=>$hotelId]);
    if (!$ok || $st->rowCount()===0) json_fail('update_failed');
  } else {
    $sql="INSERT INTO hotel_employees (hotel_id, name, email, phone, status)
          VALUES (:hid, :name, NULLIF(:email,''), NULLIF(:phone,''), :status)";
    $st=$db->prepare($sql);
    $ok=$st->execute([':hid'=>$hotelId, ':name'=>$name, ':email'=>$email, ':phone'=>$phone, ':status'=>$status]);
    if (!$ok) json_fail('insert_failed');
    $id = (int)$db->lastInsertId();
  }

  if (!empty($groupIds)) {
    // نظّف الربط وأعد الإنشاء
    $db->prepare("DELETE egm FROM employee_group_members egm
                  JOIN employee_groups g ON g.id=egm.group_id
                  WHERE egm.employee_id=? AND g.hotel_id=?")->execute([$id, $hotelId]);

    $ins = $db->prepare("INSERT IGNORE INTO employee_group_members (group_id, employee_id) VALUES (?,?)");
    foreach ($groupIds as $gid) {
      // تأكد أن المجموعة تتبع الفندق
      $ok = $db->prepare("SELECT id FROM employee_groups WHERE id=? AND hotel_id=? LIMIT 1");
      $ok->execute([$gid, $hotelId]);
      if ($ok->fetch()) $ins->execute([$gid, $id]);
    }
  }

  json_ok(['id'=>$id]);

} catch (Throwable $e) {
  json_error('server_error', ['exception'=>$e->getMessage()]);
}

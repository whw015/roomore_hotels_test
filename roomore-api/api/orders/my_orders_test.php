<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../bootstrap.php';

const ROOMORE_DEBUG_ALLOW_UID = true; // عطّلها بالإنتاج

function roomore_get_user_id(): int {
  if (ROOMORE_DEBUG_ALLOW_UID) {
    $hdrUid = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
    $qsUid  = (int)($_GET['debug_uid'] ?? 0);
    if ($hdrUid > 0) return $hdrUid;
    if ($qsUid  > 0) return $qsUid;
  }
  if (function_exists('require_auth')) {
    $u = require_auth();
    return (int)($u['id'] ?? 0);
  }
  json_response(401, ['ok'=>false,'error'=>'unauthorized']);
  return 0;
}

try {
  $user_id = roomore_get_user_id();
  $status  = isset($_GET['status']) ? trim((string)$_GET['status']) : null;

  $sql = "SELECT o.id,
                 h.slug AS hotel,
                 o.room_number AS room,
                 o.status,
                 o.total,
                 o.currency,
                 o.created_at
          FROM orders o
          JOIN hotels h ON h.id = o.hotel_id
          WHERE o.user_id = :uid";
  $p = [':uid'=>$user_id];

  if ($status) { $sql .= " AND o.status = :st"; $p[':st'] = $status; }

  $sql .= " ORDER BY o.id DESC LIMIT 100";

  $st = $pdo->prepare($sql);
  $st->execute($p);
  $rows = $st->fetchAll();

  json_response(200, ['ok'=>true, 'orders'=>$rows]);
} catch (Throwable $e) {
  json_response(500, ['ok'=>false,'error'=>'server_error']);
}

<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../../_bootstrap.php';

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
  $id = (int)($_GET['id'] ?? 0);
  if ($id <= 0) json_response(422, ['ok'=>false,'error'=>'invalid_id']);

  $st = $pdo->prepare("
    SELECT o.*, h.slug AS hotel
    FROM orders o
    JOIN hotels h ON h.id = o.hotel_id
    WHERE o.id = :id AND o.user_id = :uid
    LIMIT 1
  ");
  $st->execute([':id'=>$id, ':uid'=>$user_id]);
  $o = $st->fetch();
  if (!$o) json_response(404, ['ok'=>false,'error'=>'not_found']);

  // ملاحظة: غيّر أسماء أعمدة order_items بحسب جدولك (name_en/name_ar/price/qty/line_total)
  $it = $pdo->prepare("
    SELECT item_name AS name_en, NULL AS name_ar, unit_price AS price, quantity AS qty, total_price AS line_total
    FROM order_items WHERE order_id=:oid
    UNION ALL
    SELECT name_en, name_ar, price, qty, line_total
    FROM order_items WHERE order_id=:oid
  ");
  // ↑ السطرين يغطّون الحالتين (لو كان عندك المخطط القديم أو الجديد).
  $it->execute([':oid'=>$id]);
  $items = $it->fetchAll();

  json_response(200, [
    'ok'=>true,
    'order'=>[
      'id'        => (int)$o['id'],
      'hotel'     => $o['hotel'],
      'room'      => $o['room_number'],
      'status'    => $o['status'],
      'subtotal'  => (float)$o['subtotal'],
      'tax'       => (float)$o['tax'],
      'total'     => (float)$o['total'],
      'currency'  => $o['currency'],
      'notes'     => $o['notes'],
      'created_at'=> $o['created_at'],
      'items'     => $items
    ]
  ]);
} catch (Throwable $e) {
  json_response(500, ['ok'=>false,'error'=>'server_error']);
}

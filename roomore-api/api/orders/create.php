<?php
require_once __DIR__ . '/../bootstrap.php';
$userId  = require_bearer(); // اختياري حسب سياستك
$body    = get_json_body();
$hotelId = $body['hotelId'] ?? null;
$items   = $body['items'] ?? null; // قد تصل String أو Array
$notes   = $body['notes'] ?? null;
$total   = (float)($body['total'] ?? 0);
$currency= $body['currency'] ?? 'SAR';

if (!$hotelId || !$items) json_response(422, false, 'hotelId and items are required');
if (is_string($items)) { $tmp = json_decode($items, true); if (is_array($tmp)) $items = $tmp; }
if (!is_array($items) || empty($items)) json_response(422, false, 'invalid items');

try {
  $pdo = db(); $pdo->beginTransaction();
  $stmt = $pdo->prepare('INSERT INTO orders (hotel_id,user_id,total,currency,notes,status,created_at)
                         VALUES (?,?,?,?,?,"pending",NOW())');
  $stmt->execute([$hotelId,$userId,$total,$currency,$notes]);
  $orderId = (int)$pdo->lastInsertId();

  $itemStmt = $pdo->prepare('INSERT INTO order_items (order_id,item_id,qty,unit_price) VALUES (?,?,?,?)');
  foreach ($items as $it) {
    $itemId = $it['itemId'] ?? null; $qty=(int)($it['qty'] ?? 1); $price=(float)($it['price'] ?? 0);
    if (!$itemId) { $pdo->rollBack(); json_response(422, false, 'invalid item'); }
    $itemStmt->execute([$orderId,$itemId,$qty,$price]);
  }
  $pdo->commit();
  json_response(201, true, null, ['orderId'=>$orderId]);
} catch (Throwable $e) {
  if ($pdo?->inTransaction()) $pdo->rollBack();
  json_response(500, false, 'server_error');
}

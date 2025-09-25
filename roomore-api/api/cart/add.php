<?php
require_once dirname(__FILE__) . '/../_bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$cartId = ensure_open_cart($userId);

$payload = json_input();
$itemId = isset($payload['item_id']) ? (int)$payload['item_id'] : 0;
$qty    = isset($payload['quantity']) ? (int)$payload['quantity'] : 1;
if ($itemId <= 0 || $qty <= 0) { json_response(422, ['error' => 'item_id and quantity required']); }

$stmt = $pdo->prepare("SELECT id, active FROM service_items WHERE id=? LIMIT 1");
$stmt->execute([$itemId]);
$it = $stmt->fetch();
if (!$it || (int)$it['active'] !== 1) { json_response(404, ['error' => 'Item not available']); }

$stmt = $pdo->prepare("SELECT id, quantity FROM cart_items WHERE cart_id=? AND item_id=? LIMIT 1");
$stmt->execute([$cartId, $itemId]);
$row = $stmt->fetch();
if ($row) {
  $newQty = (int)$row['quantity'] + $qty;
  $pdo->prepare("UPDATE cart_items SET quantity=? WHERE id=?")->execute([$newQty, (int)$row['id']]);
} else {
  $pdo->prepare("INSERT INTO cart_items (cart_id, item_id, quantity) VALUES (?, ?, ?)")->execute([$cartId, $itemId, $qty]);
}
json_response(200, ['ok' => true, 'cart_id' => $cartId]);

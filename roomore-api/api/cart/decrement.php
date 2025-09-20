<?php
require_once dirname(__FILE__) . '/../_bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$cartId = ensure_open_cart($userId);

$payload = json_input();
$itemId = isset($payload['item_id']) ? (int)$payload['item_id'] : 0;
if ($itemId <= 0) { json_response(422, ['error' => 'item_id required']); }

$stmt = $pdo->prepare("SELECT id, quantity FROM cart_items WHERE cart_id=? AND item_id=? LIMIT 1");
$stmt->execute([$cartId, $itemId]);
$row = $stmt->fetch();
if (!$row) { json_response(404, ['error' => 'Not in cart']); }

$newQty = max(0, (int)$row['quantity'] - 1);
if ($newQty == 0) {
  $pdo->prepare("DELETE FROM cart_items WHERE id=?")->execute([(int)$row['id']]);
} else {
  $pdo->prepare("UPDATE cart_items SET quantity=? WHERE id=?")->execute([$newQty, (int)$row['id']]);
}
json_response(200, ['ok' => true, 'cart_id' => $cartId]);

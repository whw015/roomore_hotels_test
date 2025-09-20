<?php
require_once dirname(__FILE__) . '/../bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$cartId = ensure_open_cart($userId);

$payload = json_input();
$itemId = isset($payload['item_id']) ? (int)$payload['item_id'] : 0;
$qty    = isset($payload['quantity']) ? (int)$payload['quantity'] : -1;
if ($itemId <= 0 || $qty < 0) { json_response(422, ['error' => 'item_id and quantity required']); }

if ($qty == 0) {
  $pdo->prepare("DELETE FROM cart_items WHERE cart_id=? AND item_id=?")->execute([$cartId, $itemId]);
  json_response(200, ['ok' => true, 'cart_id' => $cartId]);
}

$stmt = $pdo->prepare("UPDATE cart_items SET quantity=? WHERE cart_id=? AND item_id=?");
$stmt->execute([$qty, $cartId, $itemId]);
if ($stmt->rowCount() === 0) {
  $pdo->prepare("INSERT INTO cart_items (cart_id, item_id, quantity) VALUES (?, ?, ?)")->execute([$cartId, $itemId, $qty]);
}
json_response(200, ['ok' => true, 'cart_id' => $cartId]);

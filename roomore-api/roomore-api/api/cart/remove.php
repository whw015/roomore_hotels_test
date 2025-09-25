<?php
require_once dirname(__FILE__) . '/../_bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$cartId = ensure_open_cart($userId);

$payload = json_input();
$itemId = isset($payload['item_id']) ? (int)$payload['item_id'] : 0;
if ($itemId <= 0) { json_response(422, ['error' => 'item_id required']); }

$pdo->prepare("DELETE FROM cart_items WHERE cart_id=? AND item_id=?")->execute([$cartId, $itemId]);
json_response(200, ['ok' => true, 'cart_id' => $cartId]);

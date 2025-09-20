<?php
require_once dirname(__FILE__) . '/../bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$cartId = ensure_open_cart($userId);

$stmt = $pdo->prepare("SELECT ci.quantity, si.price FROM cart_items ci JOIN service_items si ON si.id = ci.item_id WHERE ci.cart_id=?");
$stmt->execute([$cartId]);
$rows = $stmt->fetchAll();
if (!$rows) { json_response(422, ['error' => 'Cart is empty']); }

$total = 0.0;
foreach ($rows as $r) { $total += (float)$r['price'] * (int)$r['quantity']; }

$pdo->prepare("UPDATE carts SET status='checked_out' WHERE id=?")->execute([$cartId]);
json_response(200, ['ok' => true, 'cart_id' => $cartId, 'total' => round($total,2)]);

<?php
require_once dirname(__FILE__) . '/../_bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$cartId = ensure_open_cart($userId);

$pdo->prepare("DELETE FROM cart_items WHERE cart_id=?")->execute([$cartId]);
json_response(200, ['ok' => true, 'cart_id' => $cartId]);

<?php
require_once dirname(__FILE__) . '/../bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');
$userId = require_user_id();
$lang = (isset($_GET['lang']) && strtolower($_GET['lang']) === 'ar') ? 'ar' : 'en';
$cartId = ensure_open_cart($userId);

$fields = item_fields_for_lang($lang);
$sql = "SELECT ci.id AS cart_item_id, ci.item_id, ci.quantity,
               si.section_id, si.price, si.image_url, si.active, {$fields}
        FROM cart_items ci
        JOIN service_items si ON si.id = ci.item_id
        WHERE ci.cart_id = ?
        ORDER BY ci.id DESC";
$stmt = $pdo->prepare($sql);
$stmt->execute([$cartId]);
$rows = $stmt->fetchAll();

$total = 0.0;
foreach ($rows as &$r) {
  $r['cart_item_id'] = (int)$r['cart_item_id'];
  $r['item_id'] = (int)$r['item_id'];
  $r['section_id'] = (int)$r['section_id'];
  $r['quantity'] = (int)$r['quantity'];
  $r['price'] = (float)$r['price'];
  $r['active'] = (int)$r['active'];
  $r['line_total'] = round($r['price'] * $r['quantity'], 2);
  $total += $r['line_total'];
}

echo json_encode([
  'cart' => [
    'id' => $cartId,
    'status' => 'open',
    'items' => $rows,
    'total' => round($total, 2)
  ]
], JSON_UNESCAPED_UNICODE);

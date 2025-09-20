<?php
require dirname(__FILE__) . '/../bootstrap.php';
require_once __DIR__ . '/_helpers.php';

header('Content-Type: application/json; charset=utf-8');

try {
  // 1) اختبار التوكن
  $userId = require_user_id(); // يجب أن يعطي 401 إذا لم ترسل Authorization

  // 2) تأكيد/إنشاء عربة مفتوحة
  $cartId = ensure_open_cart($userId);

  // 3) اختبار اتصال قاعدة البيانات الأساسية
  $stmt = $pdo->query("SELECT 1 AS ok");
  $ping = $stmt->fetch();

  echo json_encode([
    'ok' => true,
    'stage' => 'smoke',
    'user_id' => $userId,
    'cart_id' => $cartId,
    'db_ping' => $ping['ok'] ?? null
  ]);
} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['ok' => false, 'stage' => 'smoke', 'error' => $e->getMessage()]);
}

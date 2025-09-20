<?php
require_once __DIR__ . '/../bootstrap.php';

$in = json_input();
$refresh = $in['refresh_token'] ?? $_POST['refresh_token'] ?? null;
$lang = $_GET['lang'] ?? $_POST['lang'] ?? 'ar';

if ($refresh) {
  try {
    $stmt = $pdo->prepare("UPDATE refresh_tokens SET revoked_at = NOW() WHERE token = ?");
    $stmt->execute([$refresh]);
  } catch (Throwable $e) {
    // نتجاهل الخطأ هنا عمداً
  }
}

json_response(200, ['message' => $lang==='ar' ? 'تم تسجيل الخروج' : 'Logged out']);

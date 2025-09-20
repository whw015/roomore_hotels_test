<?php
require_once __DIR__ . '/../_bootstrap.php'; // يجلب $pdo و $config و json_response() و json_input()

$in = json_input();
$refresh = $in['refresh_token'] ?? $_POST['refresh_token'] ?? null;
$lang = $_GET['lang'] ?? $_POST['lang'] ?? 'ar';

if (!$refresh) {
  json_response(422, ['error' => $lang==='ar' ? 'مطلوب رمز التحديث' : 'refresh_token is required']);
}

try {
  // 1) تحقق من صلاحية refresh_token (غير منتهي وغير مُبطَل)
  $stmt = $pdo->prepare("SELECT rt.id, rt.user_id, u.email, u.first_name, u.last_name
                         FROM refresh_tokens rt
                         JOIN users u ON u.id = rt.user_id
                         WHERE rt.token = ? AND rt.revoked_at IS NULL AND rt.expires_at > NOW()
                         LIMIT 1");
  $stmt->execute([$refresh]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$row) {
    json_response(401, ['error' => $lang==='ar' ? 'رمز تحديث غير صالح' : 'Invalid refresh token']);
  }

  // 2) تدوير Refresh Token (Rotate)
  $newRefresh = bin2hex(random_bytes(32));
  $pdo->beginTransaction();
  $stmt = $pdo->prepare("UPDATE refresh_tokens SET revoked_at = NOW() WHERE id = ?");
  $stmt->execute([$row['id']]);
  $stmt = $pdo->prepare("INSERT INTO refresh_tokens (user_id, token, created_at, expires_at)
                         VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY))");
  $stmt->execute([(int)$row['user_id'], $newRefresh]);
  $pdo->commit();

  // 3) إصدار Access JWT جديد (نفس مدة login.php — 3600 ثانية)
  $payload = [
    'sub' => (int)$row['user_id'],
    'iat' => time(),
    'exp' => time() + 3600,
  ];
  $newToken = Firebase\JWT\JWT::encode($payload, $config['jwt_secret'], 'HS256');

  json_response(200, [
    'token' => $newToken,
    'refresh_token' => $newRefresh,
    'user' => [
      'id' => (int)$row['user_id'],
      'email' => $row['email'],
      'first_name' => $row['first_name'],
      'last_name' => $row['last_name'],
    ],
  ]);
} catch (Throwable $e) {
  if ($pdo->inTransaction()) { $pdo->rollBack(); }
  json_response(500, ['error' => 'server_error', 'detail' => $e->getMessage()]);
}

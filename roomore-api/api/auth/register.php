<?php
require_once __DIR__ . '/../bootstrap.php';

try {
  // اقرأ JSON أولاً ثم POST كاحتياط
  $raw  = file_get_contents('php://input');
  $data = json_decode($raw, true);
  if (!is_array($data) || empty($data)) {
    $data = $_POST ?? [];
  }

  // التقاط الحقول
  $email         = strtolower(trim((string)($data['email'] ?? '')));
  $password      = (string)($data['password'] ?? '');
  $firstName     = trim((string)($data['first_name'] ?? ''));
  $lastName      = trim((string)($data['last_name'] ?? ''));
  $age           = isset($data['age']) ? (int)$data['age'] : null;
  $acceptedTerms = isset($data['accepted_terms']) ? (int)$data['accepted_terms'] : 0;

  // تحقق المدخلات
  $missing = [];
  if ($email === '')        $missing[] = 'email';
  if ($password === '')     $missing[] = 'password';
  if ($firstName === '')    $missing[] = 'first_name';
  if ($lastName === '')     $missing[] = 'last_name';
  if ($acceptedTerms !== 1) $missing[] = 'accepted_terms';

  if (!empty($missing)) {
    json_response(422, ['error' => 'Invalid payload', 'missing' => $missing]);
  }

  // عدم تكرار البريد
  $stmt = $pdo->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
  $stmt->execute([$email]);
  if ($stmt->fetch()) {
    json_response(409, ['error' => 'email_exists']);
  }

  // إدخال المستخدم (لاحظ password_hash)
  $hash = password_hash($password, PASSWORD_BCRYPT);
  $stmt = $pdo->prepare(
    'INSERT INTO users (email, password_hash, first_name, last_name, age, accepted_terms)
     VALUES (?, ?, ?, ?, ?, ?)'
  );
  $stmt->execute([$email, $hash, $firstName, $lastName, $age, $acceptedTerms]);

  $userId = (int)$pdo->lastInsertId();

  // توليد التوكن: JWT إن وُجدت المكتبة، وإلا توكن بسيط
  $token = null;
  $tokenHint = null;
  if (class_exists('\Firebase\JWT\JWT')) {
    try {
      $payload = ['sub' => $userId, 'iat' => time(), 'exp' => time() + 3600*24*7];
      $token   = \Firebase\JWT\JWT::encode($payload, $config['jwt_secret'], 'HS256');
    } catch (\Throwable $e) {
      // لو فشل الـ JWT لأي سبب، استخدم fallback بدل 500
      $token = bin2hex(random_bytes(32));
      $tokenHint = 'jwt_unavailable_fallback';
      // error_log('JWT ENCODE ERROR: '.$e->getMessage());
    }
  } else {
    $token = bin2hex(random_bytes(32));
    $tokenHint = 'jwt_class_missing_fallback';
  }

  // (اختياري) احفظ التوكن البسيط في جدول api_tokens إذا أردت التحقق لاحقًا
  // إن لم يكن لديك JWT:
  // if ($tokenHint !== null) {
  //   $expires = date('Y-m-d H:i:s', time() + 3600*24*7);
  //   $pdo->prepare('INSERT INTO api_tokens (token, user_id, expires_at) VALUES (?,?,?)')
  //       ->execute([$token, $userId, $expires]);
  // }

  $user = [
    'id'         => $userId,
    'email'      => $email,
    'first_name' => $firstName,
    'last_name'  => $lastName,
    'age'        => $age,
    'avatar_url' => null,
  ];

  // أعد الاستجابة (أضفت hint غير حساس إن تم استخدام fallback حتى تعرف السبب أثناء التطوير)
  $resp = ['token' => $token, 'user' => $user];
  if ($tokenHint !== null) { $resp['token_hint'] = $tokenHint; }

  json_response(200, $resp);

} catch (\Throwable $e) {
  // لوج اختياري أثناء التصحيح
  // error_log('REGISTER FATAL: '.$e->getMessage());
  json_response(500, ['error' => 'internal_error']);
}

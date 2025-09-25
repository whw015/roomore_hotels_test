<?php
require_once __DIR__ . '/../_bootstrap.php';

$data = json_input();
if (empty($data)) { $data = $_POST ?? []; }

$email = strtolower(trim((string)($data['email'] ?? '')));
$plain = (string)($data['password'] ?? '');

$missing = [
  'email'    => $email === '',
  'password' => $plain === '',
];
if ($missing['email'] || $missing['password']) {
  json_response(422, ['error' => 'Invalid payload', 'missing' => $missing]);
}

try {
  $stmt = $pdo->prepare('SELECT id, email, password_hash, first_name, last_name FROM users WHERE email = ? LIMIT 1');
  $stmt->execute([$email]);
  $user = $stmt->fetch();

  if (!$user) {
    json_response(401, ['error' => 'invalid credentials', 'reason' => 'email_not_found']);
  }

  if (!password_verify($plain, $user['password_hash'])) {
    json_response(401, ['error' => 'invalid credentials', 'reason' => 'password_mismatch']);
  }

  $payload = ['sub' => (int)$user['id'], 'iat' => time(), 'exp' => time() + 3600*24*7];
  $token   = \Firebase\JWT\JWT::encode($payload, $config['jwt_secret'], 'HS256');

  json_response(200, [
    'token' => $token,
    'user'  => [
      'id'         => (int)$user['id'],
      'email'      => $user['email'],
      'first_name' => $user['first_name'],
      'last_name'  => $user['last_name'],
    ],
  ]);

} catch (Throwable $e) {
  // error_log('LOGIN ERROR: '.$e->getMessage());
  json_response(500, ['error' => 'internal_error']);
}

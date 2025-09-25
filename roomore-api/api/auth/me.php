<?php
require_once __DIR__ . '/../_bootstrap.php';
$token = null;
if (function_exists('get_bearer_token')) {
  $token = get_bearer_token();
} elseif (function_exists('bearer_token')) {
  $token = bearer_token();
}

if (!$token) {
  json_response(401, ['error' => 'missing_token']);
}

try {
  $decoded = \Firebase\JWT\JWT::decode(
    $token,
    new \Firebase\JWT\Key($config['jwt_secret'], 'HS256')
  );
} catch (\Firebase\JWT\ExpiredException $e) {
  json_response(401, ['error' => 'token_expired']);
} catch (\Throwable $e) {
  json_response(401, ['error' => 'invalid_token']);
}

$userId = isset($decoded->sub) ? (int)$decoded->sub : 0;
if ($userId <= 0) {
  json_response(401, ['error' => 'invalid_token_payload']);
}

$stmt = $pdo->prepare('SELECT id, email, first_name, last_name, age, avatar_url FROM users WHERE id = ? LIMIT 1');
$stmt->execute([$userId]);
$u = $stmt->fetch();

if (!$u) {
  json_response(404, ['error' => 'user_not_found']);
}

$u['id']  = (int)$u['id'];
$u['age'] = isset($u['age']) ? (int)$u['age'] : null;

json_response(200, ['user' => $u]);

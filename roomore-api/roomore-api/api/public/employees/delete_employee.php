<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../_bootstrap.php';

function input_param(string $key): ?string {
  if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    return isset($_GET[$key]) ? trim((string)$_GET[$key]) : null;
  }
  $body = json_input();
  if (isset($body[$key])) return trim((string)$body[$key]);
  if (isset($_POST[$key])) return trim((string)$_POST[$key]);
  return null;
}

try {
  global $pdo;
  $id = input_param('id');
  if (!$id || !ctype_digit($id)) {
    json_response(200, ['ok'=>false, 'error'=>'invalid_id']);
  }

  $st = $pdo->prepare('DELETE FROM hotel_employees WHERE id = :id LIMIT 1');
  $st->execute([':id' => (int)$id]);

  json_response(200, ['ok'=>true]);

} catch (Throwable $e) {
  json_response(500, ['ok'=>false,'error'=>'server_error']);
}

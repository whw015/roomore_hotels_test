<?php
declare(strict_types=1);
function json_response(int $status, bool $ok, ?string $message = null, $data = null): never {
  http_response_code($status);
  json_response(json_encode(['ok'=>$ok,'message'=>$message,'data'=>$data], JSON_UNESCAPED_UNICODE));
  exit;
}
function get_json_body(): array {
  $raw = file_get_contents('php://input') ?: '';
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}
<?php
header('Content-Type: application/json; charset=utf-8');
$headers = function_exists('getallheaders') ? getallheaders() : [];
echo json_encode([
  'HTTP_AUTHORIZATION' => $_SERVER['HTTP_AUTHORIZATION'] ?? null,
  'Authorization' => $_SERVER['Authorization'] ?? null,
  'REDIRECT_HTTP_AUTHORIZATION' => $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? null,
  'getallheaders.Authorization' => $headers['Authorization'] ?? ($headers['authorization'] ?? null),
], JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE);

<?php
require_once __DIR__ . '/../bootstrap.php';

$raw = file_get_contents('php://input');
$asJson = json_decode($raw, true);
if (!is_array($asJson)) { $asJson = []; }

header('Content-Type: application/json; charset=utf-8');
echo json_encode([
  'method' => $_SERVER['REQUEST_METHOD'] ?? null,
  'content_type' => $_SERVER['CONTENT_TYPE'] ?? null,
  'raw' => $raw,
  'json' => $asJson,
  'post' => $_POST,
  'headers' => getallheaders(),
], JSON_UNESCAPED_UNICODE);

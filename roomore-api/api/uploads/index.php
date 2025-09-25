<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Authorization, Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }

// Simple upload handler storing files under api/uploads/storage
$baseDir = __DIR__ . '/storage';
if (!is_dir($baseDir)) {
  @mkdir($baseDir, 0775, true);
}

if (!isset($_FILES['file'])) {
  http_response_code(400);
  echo json_encode(['ok'=>false, 'error'=>'missing_file']);
  exit;
}

$file = $_FILES['file'];
if ($file['error'] !== UPLOAD_ERR_OK) {
  http_response_code(400);
  echo json_encode(['ok'=>false, 'error'=>'upload_error', 'code'=>$file['error']]);
  exit;
}

$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
$name = bin2hex(random_bytes(8)) . ($ext ? ('.' . strtolower($ext)) : '');
$dest = $baseDir . '/' . $name;

if (!move_uploaded_file($file['tmp_name'], $dest)) {
  http_response_code(500);
  echo json_encode(['ok'=>false, 'error'=>'save_failed']);
  exit;
}

// Build public URL relative to uploads endpoint
$proto = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? '';
$basePath = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
$url = $proto . '://' . $host . $basePath . '/storage/' . $name;

echo json_encode(['ok'=>true, 'url'=>$url, 'path'=>'storage/'.$name]);


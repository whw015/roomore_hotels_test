<?php
$config = require __DIR__ . '/config.php';

try {
  // بدل 50.6.35.11 بخانة الإعدادات
  $dsn = 'mysql:host=' . $config['db_host'] . ';port=3306;dbname=' . $config['db_name'] . ';charset=utf8mb4';

  $pdo = new PDO($dsn, $config['db_user'], $config['db_pass'], [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_TIMEOUT => 5,
  ]);
} catch (PDOException $e) {
  http_response_code(500);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode(['error' => 'DB connection failed']);
  exit;
}

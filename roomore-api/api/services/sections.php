<?php
require dirname(__FILE__) . '/../bootstrap.php';

$stmt = $pdo->query('SELECT id, code, title_en, title_ar FROM service_sections ORDER BY id ASC');
$rows = $stmt->fetchAll();

foreach ($rows as &$r) {
  $r['id'] = (int)$r['id'];
}
json_response(200, ['sections' => $rows]);

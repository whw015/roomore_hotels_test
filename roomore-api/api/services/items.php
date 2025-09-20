<?php
require dirname(__FILE__) . '/../bootstrap.php';

$sectionId = isset($_GET['section_id']) ? (int)$_GET['section_id'] : 0;
$lang = (isset($_GET['lang']) && strtolower($_GET['lang']) === 'ar') ? 'ar' : 'en';

if ($sectionId <= 0) {
  json_response(422, ['error' => 'section_id required']);
}

$fields = $lang === 'ar'
  ? 'name_ar AS name, description_ar AS description'
  : 'name_en AS name, description_en AS description';

$stmt = $pdo->prepare("SELECT id, $fields, price, image_url, active FROM service_items WHERE section_id=? AND active=1 ORDER BY id DESC");
$stmt->execute([$sectionId]);
$rows = $stmt->fetchAll();

foreach ($rows as &$r) {
  $r['id'] = (int)$r['id'];
  $r['price'] = (float)$r['price'];
  $r['active'] = (int)$r['active'];
}
json_response(200, ['items' => $rows]);

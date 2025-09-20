<?php
require dirname(__FILE__) . '/../bootstrap.php';

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$lang = (isset($_GET['lang']) && strtolower($_GET['lang']) === 'ar') ? 'ar' : 'en';

if ($id <= 0) { json_response(422, ['error' => 'id required']); }

$fields = $lang === 'ar'
  ? 'name_ar AS name, description_ar AS description'
  : 'name_en AS name, description_en AS description';

$stmt = $pdo->prepare("SELECT id, section_id, $fields, price, image_url, active FROM service_items WHERE id=? LIMIT 1");
$stmt->execute([$id]);
$row = $stmt->fetch();
if (!$row) { json_response(404, ['error'=>'Not found']); }

$row['id'] = (int)$row['id'];
$row['section_id'] = (int)$row['section_id'];
$row['price'] = (float)$row['price'];
$row['active'] = (int)$row['active'];

json_response(200, ['item' => $row]);

<?php
require_once __DIR__ . '/../../_multitenancy.php';

$code = $_GET['code'] ?? $_GET['hotel_code'] ?? null;
$lang = strtolower($_GET['lang'] ?? 'ar');

if (!$code) {
  json_response(422, ['error' => $lang==='ar' ? 'مطلوب code' : 'code required']);
}

$hotel = resolve_hotel_by_code($code);
if (!$hotel) {
  json_response(404, [
    'ok' => false,
    'error' => $lang==='ar' ? 'الفندق غير موجود' : 'Hotel not found'
  ]);
}

json_response(200, [
  'ok' => true,
  'hotel' => [
    'id' => (int)$hotel['id'],
    'name' => $hotel['name'],
    'slug' => $hotel['slug'],
    'city' => $hotel['city'],
  ]
]);

<?php
declare(strict_types=1);

require_once __DIR__ . '/../_bootstrap.php'; // لا تغيّر
header('Content-Type: application/json; charset=utf-8');

try {
  $db = db(); // من _bootstrap.php
  if (!$db) {
    json_error('db_unavailable');
  }

  $body = get_json_body(); // موجود في _bootstrap.php
  $code  = strtolower(trim($body['code'] ?? ''));          // كود الفندق (مثل RMR001)
  $id    = isset($body['id']) ? (int)$body['id'] : null;   // لو موجود → تعديل
  $parentId = $body['parentSectionId'] ?? null;
  if ($parentId === '' || $parentId === 'null') $parentId = null;
  $parentId = $parentId !== null ? (int)$parentId : null;

  $titleAr = trim((string)($body['name']['ar'] ?? ''));
  $titleEn = trim((string)($body['name']['en'] ?? ''));
  $sort    = isset($body['order']) ? (int)$body['order'] : 0;
  $active  = isset($body['isActive']) ? (int)$body['isActive'] : 1;
  $secCode = trim((string)($body['sectionCode'] ?? '')); // اختياري code داخلي للقسم

  if ($code === '' || ($titleAr === '' && $titleEn === '')) {
    json_fail('invalid_input', ['hint' => 'code and at least one of name.ar|name.en are required']);
  }

  // الفندق
  $st = $db->prepare("SELECT id FROM hotels WHERE LOWER(code)=LOWER(?) LIMIT 1");
  $st->execute([$code]);
  $hotel = $st->fetch(PDO::FETCH_ASSOC);
  if (!$hotel) json_fail('hotel_not_found', ['code'=>$code]);
  $hotelId = (int)$hotel['id'];

  // upsert
  if ($id) {
    // تحديث
    $sql = "UPDATE service_sections
              SET parentSectionId = :parentId,
                  title_ar = :ar,
                  title_en = :en,
                  sort_order = :sort,
                  active = :active,
                  code = COALESCE(NULLIF(:scode,''), code)
            WHERE id = :id AND hotel_id = :hotelId";
    $st = $db->prepare($sql);
    $ok = $st->execute([
      ':parentId' => $parentId,
      ':ar' => $titleAr,
      ':en' => $titleEn,
      ':sort' => $sort,
      ':active' => $active,
      ':scode' => $secCode,
      ':id' => $id,
      ':hotelId' => $hotelId
    ]);
    if (!$ok || $st->rowCount()===0) json_fail('update_failed');
    json_ok(['id'=>$id]);
  } else {
    // إنشاء
    $sql = "INSERT INTO service_sections (hotel_id, parentSectionId, title_ar, title_en, sort_order, active, code)
            VALUES (:hotelId, :parentId, :ar, :en, :sort, :active, NULLIF(:scode,''))";
    $st = $db->prepare($sql);
    $ok = $st->execute([
      ':hotelId' => $hotelId,
      ':parentId' => $parentId,
      ':ar' => $titleAr,
      ':en' => $titleEn,
      ':sort' => $sort,
      ':active' => $active,
      ':scode' => $secCode,
    ]);
    if (!$ok) json_fail('insert_failed');
    $newId = (int)$db->lastInsertId();
    json_ok(['id'=>$newId]);
  }

} catch (Throwable $e) {
  json_error('server_error', ['exception'=>$e->getMessage()]);
}

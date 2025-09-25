<?php
declare(strict_types=1);

require_once __DIR__ . '/../_bootstrap.php';
header('Content-Type: application/json; charset=utf-8');

try {
  $db = db();
  if (!$db) json_error('db_unavailable');

  $b = get_json_body();
  $code = strtolower(trim($b['code'] ?? '')); // كود الفندق
  $id   = isset($b['id']) ? (int)$b['id'] : null;

  $sectionId = (int)($b['sectionId'] ?? 0);
  $nameAr = trim((string)($b['name']['ar'] ?? ''));
  $nameEn = trim((string)($b['name']['en'] ?? ''));
  $descAr = trim((string)($b['description']['ar'] ?? ''));
  $descEn = trim((string)($b['description']['en'] ?? ''));
  $price  = (float)($b['price'] ?? 0);
  $currency = trim((string)($b['currency'] ?? ''));
  $active = isset($b['isAvailable']) ? (int)$b['isAvailable'] : 1;
  $imageUrl = trim((string)($b['imageUrl'] ?? '')); // اختياري

  if ($code==='' || $sectionId<=0 || ($nameAr==='' && $nameEn==='')) {
    json_fail('invalid_input', ['hint'=>'code, sectionId, and name are required']);
  }

  // تأكد أن القسم يتبع فندق code
  $st = $db->prepare("SELECT s.id FROM service_sections s
                      JOIN hotels h ON s.hotel_id=h.id
                      WHERE s.id=? AND LOWER(h.code)=LOWER(?) LIMIT 1");
  $st->execute([$sectionId, $code]);
  $sec = $st->fetch(PDO::FETCH_ASSOC);
  if (!$sec) json_fail('section_not_found_or_mismatch');

  if ($id) {
    $sql = "UPDATE service_items
              SET section_id=:sid, name_ar=:ar, name_en=:en,
                  description_ar=:dar, description_en=:den,
                  price=:price, currency=:cur, active=:act,
                  image_url = NULLIF(:img,'')
            WHERE id=:id";
    $st = $db->prepare($sql);
    $ok = $st->execute([
      ':sid'=>$sectionId, ':ar'=>$nameAr, ':en'=>$nameEn,
      ':dar'=>$descAr, ':den'=>$descEn,
      ':price'=>$price, ':cur'=>$currency, ':act'=>$active,
      ':img'=>$imageUrl, ':id'=>$id
    ]);
    if (!$ok || $st->rowCount()===0) json_fail('update_failed');
    json_ok(['id'=>$id]);
  } else {
    $sql = "INSERT INTO service_items
              (section_id, name_ar, name_en, description_ar, description_en, price, currency, active, image_url)
            VALUES (:sid, :ar, :en, :dar, :den, :price, :cur, :act, NULLIF(:img,''))";
    $st = $db->prepare($sql);
    $ok = $st->execute([
      ':sid'=>$sectionId, ':ar'=>$nameAr, ':en'=>$nameEn,
      ':dar'=>$descAr, ':den'=>$descEn, ':price'=>$price,
      ':cur'=>$currency, ':act'=>$active, ':img'=>$imageUrl
    ]);
    if (!$ok) json_fail('insert_failed');
    $newId = (int)$db->lastInsertId();
    json_ok(['id'=>$newId]);
  }

} catch (Throwable $e) {
  json_error('server_error', ['exception'=>$e->getMessage()]);
}

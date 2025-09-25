<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

// يستخدم البوتستراب القديم الشغال عندك
require_once __DIR__ . '/../../_bootstrap.php';

/**
 * إدخال (GET أو JSON POST):
 *   - code=RMR001  أو hotel_id=1
 *   - parentSectionId=<اختياري> لتقييد المستوى
 *   - lang=ar|en   (اختياري لتحديد لسان افتراضي عند غياب الآخر)
 *   - includeSub=1 (اختياري: لو =1 يبحث عناصر الأقسام الفرعية أيضاً)
 *
 * مخرجات:
 * {
 *   ok: true,
 *   sections: [
 *     {
 *       id, parentSectionId, name:{ar,en},
 *       items: [ { id, sectionId, isAvailable, price, currency, name:{ar,en}, description:{ar,en}, imageUrls } ]
 *     }, ...
 *   ]
 * }
 */

function input_param(string $key): ?string {
  if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    return isset($_GET[$key]) ? trim((string)$_GET[$key]) : null;
  }
  $j = json_input();
  return isset($j[$key]) ? trim((string)$j[$key]) : null;
}

function resolve_hotel_id(PDO $pdo, ?string $hotelIdOrCode): ?int {
  if (!$hotelIdOrCode || $hotelIdOrCode === '') return null;
  if (ctype_digit($hotelIdOrCode)) return (int)$hotelIdOrCode;

  $needle = strtolower(preg_replace('/\s+/', '', $hotelIdOrCode));
  $st = $pdo->prepare('SELECT id FROM hotels WHERE LOWER(COALESCE(code,""))=:q OR LOWER(COALESCE(slug,""))=:q LIMIT 1');
  $st->execute([':q' => $needle]);
  $row = $st->fetch(PDO::FETCH_ASSOC);
  return $row ? (int)$row['id'] : null;
}

/** إرجاع كل الأقسام لهذا الفندق (اختياري تقييدها بالأب) */
function fetch_sections(PDO $pdo, int $hotelId, ?string $parentId): array {
  if ($parentId === null || $parentId === '') {
    $sql = 'SELECT id, parentSectionId, title_ar, title_en
            FROM service_sections WHERE hotel_id=:hid ORDER BY id';
    $st = $pdo->prepare($sql);
    $st->execute([':hid' => $hotelId]);
  } else {
    $sql = 'SELECT id, parentSectionId, title_ar, title_en
            FROM service_sections WHERE hotel_id=:hid AND parentSectionId=:pid ORDER BY id';
    $st = $pdo->prepare($sql);
    $st->execute([':hid' => $hotelId, ':pid' => $parentId]);
  }

  $out = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $out[] = [
      'id'              => (string)$r['id'],
      'parentSectionId' => $r['parentSectionId'] !== null ? (string)$r['parentSectionId'] : null,
      'name'            => [
        'ar' => (string)($r['title_ar'] ?? ''),
        'en' => (string)($r['title_en'] ?? ''),
      ],
    ];
  }
  return $out;
}

/** عناصر قسم واحد (نشطة فقط) */
function fetch_items_for_section(PDO $pdo, int $hotelId, string $sectionId): array {
  $sql = 'SELECT id, section_id, name_ar, name_en, description_ar, description_en, price, image_url, active
          FROM service_items
          WHERE hotel_id=:hid AND section_id=:sid AND active=1
          ORDER BY id';
  $st = $pdo->prepare($sql);
  $st->execute([':hid' => $hotelId, ':sid' => $sectionId]);

  $items = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $items[] = [
      'id'          => (string)$r['id'],
      'sectionId'   => (string)$r['section_id'],
      'isAvailable' => (int)$r['active'] === 1,
      'price'       => isset($r['price']) ? (float)$r['price'] : 0.0,
      'currency'    => '', // لا يوجد عمود للعملة في السكيمـا الحالية
      'name'        => [
        'ar' => (string)($r['name_ar'] ?? ''),
        'en' => (string)($r['name_en'] ?? ''),
      ],
      'description' => [
        'ar' => (string)($r['description_ar'] ?? ''),
        'en' => (string)($r['description_en'] ?? ''),
      ],
      'imageUrls'   => array_values(array_filter([(string)($r['image_url'] ?? '')])),
      'options'     => [],
    ];
  }
  return $items;
}

/** جلب كل أبناء قسم (مباشر فقط) */
function fetch_child_sections(PDO $pdo, int $hotelId, string $parentId): array {
  $sql = 'SELECT id FROM service_sections WHERE hotel_id=:hid AND parentSectionId=:pid';
  $st = $pdo->prepare($sql);
  $st->execute([':hid' => $hotelId, ':pid' => $parentId]);
  $ids = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $ids[] = (string)$r['id'];
  }
  return $ids;
}

try {
  global $pdo;

  $code      = input_param('code');
  $hotelArg  = input_param('hotel_id');
  $parentId  = input_param('parentSectionId'); // اختياري
  $lang      = input_param('lang');            // اختياري ar|en
  $includeSub = input_param('includeSub');     // اختياري 1|0

  $hotelId = $hotelArg !== null ? resolve_hotel_id($pdo, $hotelArg) : resolve_hotel_id($pdo, $code);
  if (!$hotelId) {
    json_response(200, ['ok' => false, 'error' => 'hotel_not_found']);
  }

  $sections = fetch_sections($pdo, $hotelId, $parentId);

  $result = [];
  foreach ($sections as $sec) {
    // عناصر القسم نفسه
    $items = fetch_items_for_section($pdo, $hotelId, $sec['id']);

    // لو مطلوب تضمين عناصر الأقسام الفرعية أيضاً
    if ($includeSub === '1') {
      $children = fetch_child_sections($pdo, $hotelId, $sec['id']);
      foreach ($children as $childId) {
        $items = array_merge($items, fetch_items_for_section($pdo, $hotelId, $childId));
      }
    }

    // لا نعيد إلا الأقسام التي لديها عناصر فعلًا
    if (!empty($items)) {
      // إن أردت فرض لسان افتراضي (إذا أحدهما فاضي)، نستعمل الآخر
      if ($lang === 'ar' || $lang === 'en') {
        $name = $sec['name'];
        if ($lang === 'ar' && $name['ar'] === '' && $name['en'] !== '') $name['ar'] = $name['en'];
        if ($lang === 'en' && $name['en'] === '' && $name['ar'] !== '') $name['en'] = $name['ar'];
        $sec['name'] = $name;
      }

      $sec['items'] = $items;
      $result[] = $sec;
    }
  }

  json_response(200, ['ok' => true, 'sections' => $result]);

} catch (Throwable $e) {
  // error_log('[sections_with_items] '.$e->getMessage());
  json_response(500, ['ok' => false, 'error' => 'server_error']);
}

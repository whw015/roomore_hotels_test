<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../_bootstrap.php';

/**
 * إدخال:
 *   - GET:  ?code=RMR001&sectionId=123  أو  ?hotel_id=1&sectionId=123
 *   - POST: { "code":"RMR001", "sectionId":"123" } أو { "hotel_id":1, "sectionId":"123" }
 * مخرجات:
 * { ok: true, items: [ { id, sectionId, isAvailable, price, currency, name:{ar,en}, description:{ar,en}, imageUrls } ] }
 * ملاحظة: لا يوجد currency بالسكيمـا، سنرجعها كسلسلة فارغة "".
 */

function input_param(string $key): ?string {
  if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    return isset($_GET[$key]) ? trim((string)$_GET[$key]) : null;
  }
  $body = json_input();
  return isset($body[$key]) ? trim((string)$body[$key]) : null;
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

try {
  global $pdo;

  $code      = input_param('code');
  $hotelArg  = input_param('hotel_id');
  $sectionId = input_param('sectionId');

  if (!$sectionId || $sectionId === '') {
    json_response(200, ['ok' => false, 'error' => 'missing_sectionId']);
  }

  $hotelId = $hotelArg !== null ? resolve_hotel_id($pdo, $hotelArg) : resolve_hotel_id($pdo, $code);
  if (!$hotelId) {
    json_response(200, ['ok' => false, 'error' => 'hotel_not_found']);
  }

  $sql = 'SELECT id, section_id, name_ar, name_en, description_ar, description_en,
                 price, image_url, active
          FROM service_items
          WHERE hotel_id = :hid AND section_id = :sid AND active = 1
          ORDER BY id';
  $st = $pdo->prepare($sql);
  $st->execute([':hid' => $hotelId, ':sid' => $sectionId]);

  $items = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $items[] = [
      'id'              => (string)$r['id'],
      'sectionId'       => (string)$r['section_id'],
      'isAvailable'     => (int)$r['active'] === 1,
      'price'           => isset($r['price']) ? (float)$r['price'] : 0.0,
      'currency'        => '', // لا يوجد عمود عملة في السكيمـا الحالية
      'name'            => [
        'ar' => (string)($r['name_ar'] ?? ''),
        'en' => (string)($r['name_en'] ?? ''),
      ],
      'description'     => [
        'ar' => (string)($r['description_ar'] ?? ''),
        'en' => (string)($r['description_en'] ?? ''),
      ],
      'imageUrls'       => array_values(array_filter([(string)($r['image_url'] ?? '')])),
      'options'         => [], // غير موجودة بالسكيمـا
    ];
  }

  json_response(200, ['ok' => true, 'items' => $items]);

} catch (Throwable $e) {
  // error_log('[items_by_section] '.$e->getMessage());
  json_response(500, ['ok' => false, 'error' => 'server_error']);
}

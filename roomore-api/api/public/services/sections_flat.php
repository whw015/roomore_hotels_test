<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../_bootstrap.php'; // يعرّف $pdo, json_response(), json_input()

/**
 * إدخال:
 *   - GET:  ?code=RMR001  أو  ?hotel_id=1
 *   - POST: { "code":"RMR001" } أو { "hotel_id":1 }
 * مخرجات:
 * { ok: true, sections: [ { id, parentSectionId, isRoot, name:{ar,en} } ... ] }
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

  $code     = input_param('code');
  $hotelArg = input_param('hotel_id');
  $hotelId  = $hotelArg !== null ? resolve_hotel_id($pdo, $hotelArg) : resolve_hotel_id($pdo, $code);

  if (!$hotelId) {
    json_response(200, ['ok' => false, 'error' => 'hotel_not_found']);
  }

  $sql = 'SELECT id, hotel_id, parentSectionId, title_ar, title_en
          FROM service_sections
          WHERE hotel_id = :hid
          ORDER BY id';
  $st = $pdo->prepare($sql);
  $st->execute([':hid' => $hotelId]);

  $sections = [];
  while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
    $sections[] = [
      'id'              => (string)$r['id'],
      'parentSectionId' => isset($r['parentSectionId']) && $r['parentSectionId'] !== null ? (string)$r['parentSectionId'] : null,
      'isRoot'          => empty($r['parentSectionId']),
      'name'            => [
        'ar' => (string)($r['title_ar'] ?? ''),
        'en' => (string)($r['title_en'] ?? ''),
      ],
    ];
  }

  json_response(200, ['ok' => true, 'sections' => $sections]);

} catch (Throwable $e) {
  // error_log('[sections_flat] '.$e->getMessage());
  json_response(500, ['ok' => false, 'error' => 'server_error']);
}

<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

// Use project bootstrap (provides $pdo, json_response(), bearer_token(), etc.)
require_once __DIR__ . '/../bootstrap.php';

/**
 * Accepts: GET ?code=<slug or URL ending with slug>
 * Looks up hotel by `hotels.slug`, or alias in `hotel_qr_codes.code`
 * Returns: { ok: true, hotel: { code: <slug>, name: <name> } }  OR  { ok:false, error: '...' }
 */

$raw = isset($_GET['code']) ? trim((string)$_GET['code']) : '';
if ($raw === '') { json_response(200, ['ok'=>false,'error'=>'invalid_qr']); }

// If the QR is a URL, take the last path segment as slug
$slug = $raw;
if (preg_match('~https?://~i', $raw)) {
  $slug = trim(parse_url($raw, PHP_URL_PATH) ?? '', '/');
  $slug = basename($slug);
}
$slug = strtolower($slug);

// Basic slug format
if (!preg_match('/^[a-z0-9\-_]{2,64}$/', $slug)) {
  json_response(200, ['ok'=>false,'error'=>'invalid_qr']);
}

try {
  // 1) Try hotels.slug
  $stmt = $pdo->prepare('SELECT id, slug, name FROM hotels WHERE slug = :s LIMIT 1');
  $stmt->execute([':s'=>$slug]);
  $hotel = $stmt->fetch();

  if (!$hotel) {
    // 2) Try alias table
    $stmt = $pdo->prepare("
      SELECT h.id, h.slug, h.name
      FROM hotel_qr_codes q
      JOIN hotels h ON h.id = q.hotel_id
      WHERE q.code = :c
      LIMIT 1
    ");
    $stmt->execute([':c'=>$slug]);
    $hotel = $stmt->fetch();
  }

  if (!$hotel) {
    json_response(200, ['ok'=>false,'error'=>'hotel_not_found']);
  }

  // Keep key 'code' for Flutter compatibility (value is slug)
  json_response(200, [
    'ok' => true,
    'hotel' => [
      'code' => $hotel['slug'],
      'name' => $hotel['name'],
    ]
  ]);

} catch (Throwable $e) {
  json_response(500, ['ok'=>false, 'error'=>'server_error']);
}

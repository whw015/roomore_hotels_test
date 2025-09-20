<?php
// roomore-api/api/public/guests/is_current.php
header('Content-Type: application/json; charset=utf-8');

function out($arr, $code = 200) {
  http_response_code($code);
  echo json_encode($arr, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
  exit;
}

// bootstrap (we're in public/guests)
$loaded = false;
foreach ([__DIR__ . '/../../_bootstrap.php', __DIR__ . '/../bootstrap.php'] as $p) {
  if (is_file($p)) { require_once $p; $loaded = true; break; }
}
if (!$loaded) {
  out(['ok' => false, 'error' => 'bootstrap_not_found'], 500);
}

function get_bearer_token(): ?string {
  $headers = function_exists('getallheaders') ? getallheaders() : [];
  $auth = '';
  foreach ($headers as $k => $v) {
    if (strtolower($k) === 'authorization') { $auth = $v; break; }
  }
  if (!$auth && isset($_SERVER['HTTP_AUTHORIZATION'])) $auth = $_SERVER['HTTP_AUTHORIZATION'];
  if (!$auth) return null;
  if (stripos($auth, 'Bearer ') === 0) return trim(substr($auth, 7));
  return null;
}

$token = get_bearer_token();
if (!$token) out(['ok' => false, 'error' => 'no_bearer_token'], 401);

$authUserId = null;
if (function_exists('require_auth')) {
  $auth = require_auth();
  if (is_array($auth) && isset($auth['id'])) {
    $authUserId = (int)$auth['id'];
  } elseif (isset($auth_user['id'])) {
    $authUserId = (int)$auth_user['id'];
  } elseif (function_exists('current_user_id')) {
    $authUserId = (int) current_user_id();
  }
}

if (!$authUserId) {
  $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
  $host   = $_SERVER['HTTP_HOST'] ?? 'localhost';
  $script = $_SERVER['SCRIPT_NAME'] ?? '/';
  $mePath = preg_replace('#/public/guests/[^/]+$#', '/auth/me.php', $script);
  if (!$mePath) $mePath = '/roomore-api/api/auth/me.php';
  $meUrl  = $scheme . '://' . $host . $mePath;

  $ch = curl_init($meUrl);
  curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => ['Authorization: Bearer ' . $token, 'Accept: application/json'],
    CURLOPT_TIMEOUT        => 10,
  ]);
  $body = curl_exec($ch);
  $err  = curl_error($ch);
  $code = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
  curl_close($ch);

  if ($err || $code >= 400 || !$body) {
    out(['ok' => false, 'error' => 'auth_proxy_failed', 'status' => $code, 'message' => $err], 401);
  }

  $json = json_decode($body, true);
  $user = (is_array($json) && isset($json['user']) && is_array($json['user'])) ? $json['user'] : null;
  if (!$user || !isset($user['id'])) {
    out(['ok' => false, 'error' => 'auth_proxy_invalid_response', 'raw' => $json], 401);
  }
  $authUserId = (int)$user['id'];
}

if (!$authUserId) out(['ok' => false, 'error' => 'unauthorized_user_id'], 401);

// hotel_code
$hotelCode = '';
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
  $hotelCode = isset($_GET['hotel_code']) ? trim($_GET['hotel_code']) : '';
} else {
  $raw = file_get_contents('php://input');
  $in  = json_decode($raw, true);
  if (!is_array($in)) { $in = $_POST ?? []; }
  $hotelCode = trim($in['hotel_code'] ?? $in['code'] ?? '');
}
if ($hotelCode === '') out(['ok' => false, 'error' => 'hotel_code_required'], 422);

try {
  // resolve hotel
  $st = $pdo->prepare("SELECT id, name, slug FROM hotels WHERE slug = ? LIMIT 1");
  $st->execute([$hotelCode]);
  $hotel = $st->fetch();

  if (!$hotel) {
    $sql = "SELECT h.id, h.name, h.slug
              FROM hotel_qr_codes q
              JOIN hotels h ON h.id = q.hotel_id
             WHERE q.code = ?
             LIMIT 1";
    $st = $pdo->prepare($sql);
    $st->execute([$hotelCode]);
    $hotel = $st->fetch();
  }
  if (!$hotel) out(['ok' => false, 'error' => 'hotel_not_found'], 404);

  $hotelId   = (int)$hotel['id'];
  $hotelName = $hotel['name'];
  $hotelSlug = $hotel['slug'];

  // hotel_guests first
  $st = $pdo->prepare("SELECT id, status FROM hotel_guests
                        WHERE hotel_id = ? AND user_id = ?
                          AND status IN ('active','checked_in')
                        ORDER BY id DESC
                        LIMIT 1");
  $st->execute([$hotelId, $authUserId]);
  $hg = $st->fetch();
  $isGuest = (bool)$hg;
  $roomNumber = null;

  // stays active (to fetch room_number)
  $st = $pdo->prepare("SELECT id, room_number FROM stays
                        WHERE hotel_id = ? AND user_id = ?
                          AND status = 'active'
                        ORDER BY id DESC
                        LIMIT 1");
  $st->execute([$hotelId, $authUserId]);
  $s = $st->fetch();
  if ($s && isset($s['room_number']) && $s['room_number'] !== null && $s['room_number'] !== '') {
    $roomNumber = $s['room_number'];
    $isGuest = true; // ensure true if active stay exists
  }

  out([
    'ok'          => true,
    'hotel'       => ['id' => $hotelId, 'name' => $hotelName, 'slug' => $hotelSlug],
    'user_id'     => $authUserId,
    'is_guest'    => $isGuest,
    'room_number' => $roomNumber
  ], 200);

} catch (Throwable $e) {
  out(['ok' => false, 'error' => 'exception', 'message' => $e->getMessage()], 500);
}

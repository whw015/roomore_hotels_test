<?php
require_once __DIR__ . '/../multitenancy.php';
// helper: read raw JSON safely
function read_json_body() {
  $raw = file_get_contents('php://input');
  if (!$raw) return [];
  $j = json_decode($raw, true);
  return is_array($j) ? $j : [];
}

// 1) اجمع كل المصادر: JSON ثم POST ثم GET (الأولوية لليمين في array_merge)
$payload_json = read_json_body();
$all = array_merge($_GET ?? [], $_POST ?? [], $payload_json);

// 2) التقط القيم وطبّعها
$code = trim((string)($all['code'] ?? $all['hotel_code'] ?? ''));
$email = trim((string)($all['email'] ?? ''));
$phone = trim((string)($all['phone'] ?? $all['mobile'] ?? ''));
$lang  = strtolower(trim((string)($all['lang'] ?? 'ar')));

// 3) تطبيع بسيط للهاتف (إزالة الفراغات والرموز الشائعة)
if ($phone !== '') {
  $phone = preg_replace('/[^\d+]/', '', $phone);
}

// 4) تحقق من المدخلات
if ($code === '') {
  json_response(422, ['error' => $lang==='ar' ? 'مطلوب hotel_code' : 'hotel_code required']);
}
if ($email === '' && $phone === '') {
  json_response(422, ['error' => $lang==='ar' ? 'مطلوب بريد أو جوال' : 'email or phone required']);
}

// 5) احضر الفندق
$hotel = require_hotel($code);
$hotel_id = (int)$hotel['id'];

// 6) الاستعلام (يطابق إمّا البريد أو الجوال ويعتبر الإقامة فعّالة)
$sql = "SELECT id, first_name, last_name, room_number, check_in, check_out, status
        FROM stays
        WHERE hotel_id = ?
          AND (
            (guest_email IS NOT NULL AND guest_email = ?)
            OR
            (guest_phone IS NOT NULL AND guest_phone = ?)
          )
          AND (
            status = 'active'
            OR (check_in IS NOT NULL AND check_out IS NOT NULL AND NOW() BETWEEN check_in AND check_out)
          )
        ORDER BY id DESC
        LIMIT 1";
$stmt = $pdo->prepare($sql);
$stmt->execute([$hotel_id, $email, $phone]);
$stay = $stmt->fetch();

$auth = try_require_auth();
if ($auth && isset($auth['user_id'])) {
  $pdo->prepare("UPDATE stays SET user_id=? WHERE id=? AND (user_id IS NULL OR user_id=0)")
      ->execute([$auth['user_id'], $stay['id']]);
}

if (!$stay) {
  json_response(200, [
    'ok' => false,
    'reason' => 'not_registered',
    'message' => $lang==='ar'
      ? 'عفواً: لم يتم تسجيلك ضمن ضيوف الفندق، الرجاء مراجعة الاستقبال'
      : 'Sorry: you are not registered as a hotel guest, please check with reception'
  ]);
}

// 7) الرسالة حسب اللغة
$guest = trim(($stay['first_name'] ?? '') . ' ' . ($stay['last_name'] ?? ''));
$greeting = ($lang === 'ar')
  ? "مرحبًا بك " . ($guest ?: 'ضيفنا الكريم') . " في " . $hotel['name'] . " نتمنى لك إقامة سعيدة / رقم الغرفة " . ($stay['room_number'] ?? '-')
  : "Welcome " . ($guest ?: 'our valued guest') . " to " . $hotel['name'] . ". We wish you a pleasant stay. / Room " . ($stay['room_number'] ?? '-');

json_response(200, [
  'ok' => true,
  'hotel' => ['id' => $hotel_id, 'name' => $hotel['name'], 'slug' => $hotel['slug']],
  'stay' => [
    'id' => (int)$stay['id'],
    'room_number' => $stay['room_number'],
    'check_in' => $stay['check_in'],
    'check_out' => $stay['check_out'],
    'status' => $stay['status'],
  ],
  'greeting' => $greeting
]);

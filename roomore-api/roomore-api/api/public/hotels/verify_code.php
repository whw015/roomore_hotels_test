<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

// استدعاء البوتستراب القديم كما هو (يوفّر $pdo, json_response(), json_input(), bearer_token()..)
require_once __DIR__ . '/../../_bootstrap.php';

/**
 * يقبل:
 *   - GET ?code=RMR001
 *   - أو JSON: { "code": "RMR001" }
 *
 * يتحقق من الفندق بـ hotels.code أو hotels.slug (كلاهما lower-case) ويعيد نفس شكل الاستجابة
 * المستخدم في verify_qr.php للمحافظة على التوافق مع تطبيق Flutter:
 *
 *  { ok: true, hotel: { code: "...", name: "...", slug: "..." } }
 *  أو { ok: false, error: "not_found" | "invalid_code" | "server_error" }
 */

function input_code(): string {
  // لو GET
  if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    return isset($_GET['code']) ? trim((string)$_GET['code']) : '';
  }
  // لو POST/PUT.. نستعمل دالة json_input() المعرفة في _bootstrap.php
  $body = json_input();
  return isset($body['code']) ? trim((string)$body['code']) : '';
}

$code = input_code();
if ($code === '') {
  json_response(200, ['ok' => false, 'error' => 'invalid_code']);
}

$needle = strtolower(preg_replace('/\s+/', '', $code)); // إزالة المسافات وتخفيض الحروف

try {
  // نبحث بالـ code أو الـ slug
  $stmt = $pdo->prepare(
    'SELECT id, code, slug, name 
     FROM hotels 
     WHERE LOWER(COALESCE(code, "")) = :q OR LOWER(COALESCE(slug, "")) = :q 
     LIMIT 1'
  );
  $stmt->execute([':q' => $needle]);
  $hotel = $stmt->fetch();

  if (!$hotel) {
    json_response(200, ['ok' => false, 'error' => 'not_found']);
  }

  // نرجّع نفس الهيكل المستخدم في verify_qr.php (الحقل code يساوي slug هناك)
  // هنا نحافظ على الحقلين: code (إن وُجد) وslug لزيادة التوافق للأمام
  json_response(200, [
    'ok'    => true,
    'hotel' => [
      'code' => $hotel['code'] !== null && $hotel['code'] !== '' ? $hotel['code'] : $hotel['slug'],
      'slug' => $hotel['slug'],
      'name' => $hotel['name'],
    ],
  ]);

} catch (Throwable $e) {
  // لا نطبع رسالة الخطأ الداخلية؛ نحافظ على واجهة موحّدة
  json_response(500, ['ok' => false, 'error' => 'server_error']);
}

<?php
// roomore-api/api/public/dev/add_test_guest.php
// TEMP endpoint to add user (default id=1 test@example.com) as ACTIVE guest in a hotel by code.

// 1) حمّل نفس البوتستراب المستخدم في auth/*
require_once __DIR__ . '/../../_bootstrap.php';

header('Content-Type: application/json; charset=utf-8');

function out($arr, $code = 200) {
  http_response_code($code);
  echo json_encode($arr, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
  exit;
}

try {
  // 2) الإدخال
  $raw = file_get_contents('php://input');
  $in  = json_decode($raw, true);
  if (!is_array($in) || empty($in)) { $in = $_POST ?? []; }

  $hotelCode = trim($in['hotel_code'] ?? $in['code'] ?? '');
  $userId    = isset($in['user_id']) ? (int)$in['user_id'] : null;
  $email     = isset($in['email']) ? trim($in['email']) : null;
  $roomNo    = trim($in['room_number'] ?? '101'); // اختياري

  if ($hotelCode === '') {
    out(['ok' => false, 'error' => 'hotel_code_required'], 422);
  }
  // افتراضيًا حسب طلبك: user=1 (test@example.com)
  if (!$userId && !$email) { $userId = 1; }

  // 3) المستخدم
  if ($userId) {
    $st = $pdo->prepare("SELECT id, email, first_name, last_name FROM users WHERE id = ? LIMIT 1");
    $st->execute([$userId]);
  } else {
    $st = $pdo->prepare("SELECT id, email, first_name, last_name FROM users WHERE email = ? LIMIT 1");
    $st->execute([$email]);
  }
  $user = $st->fetch();
  if (!$user) out(['ok' => false, 'error' => 'user_not_found'], 404);

  $userId   = (int)$user['id'];
  $userMail = $user['email'];

  // 4) الفندق عبر slug في hotels أو code في hotel_qr_codes
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

  // 5) إنشاء/تثبيت إقامة ACTIVE و hotel_guests ACTIVE
  $pdo->beginTransaction();

  // إعادة استخدام إقامة ACTIVE إن وُجدت
  $st = $pdo->prepare("SELECT id FROM stays
                       WHERE hotel_id = ? AND user_id IS NOT NULL AND user_id = ? AND status = 'active'
                       ORDER BY id DESC LIMIT 1");
  $st->execute([$hotelId, $userId]);
  $stay = $st->fetch();

  $now   = new DateTime('now');
  $outDT = (clone $now)->modify('+2 days');

  if ($stay) {
    $stayId = (int)$stay['id'];
    $pdo->prepare("UPDATE stays SET check_in = IFNULL(check_in, ?), check_out = ? WHERE id = ? AND status='active'")
        ->execute([$now->format('Y-m-d H:i:s'), $outDT->format('Y-m-d H:i:s'), $stayId]);
  } else {
    $st = $pdo->prepare("INSERT INTO stays
      (hotel_id, guest_email, first_name, last_name, room_number, check_in, check_out, status, user_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, 'active', ?)");
    $st->execute([
      $hotelId,
      $userMail,
      $user['first_name'],
      $user['last_name'],
      $roomNo,
      $now->format('Y-m-d H:i:s'),
      $outDT->format('Y-m-d H:i:s'),
      $userId
    ]);
    $stayId = (int)$pdo->lastInsertId();
  }

  // hotel_guests: إن وُجد ACTIVE/checked_in لنفس (hotel_id,user_id) حدّثه؛ وإلا أنشئ جديد
  $st = $pdo->prepare("SELECT id FROM hotel_guests
                       WHERE hotel_id = ? AND user_id = ? AND status IN ('active','checked_in')
                       ORDER BY id DESC LIMIT 1");
  $st->execute([$hotelId, $userId]);
  $hg = $st->fetch();

  if ($hg) {
    $hotelGuestId = (int)$hg['id'];
    $pdo->prepare("UPDATE hotel_guests SET status='active', room_number=?, check_in=?, check_out=?, updated_at=NOW() WHERE id=?")
        ->execute([$roomNo, $now->format('Y-m-d'), $outDT->format('Y-m-d'), $hotelGuestId]);
  } else {
    $st = $pdo->prepare("INSERT INTO hotel_guests
      (hotel_id, user_id, room_number, status, check_in, check_out, created_at)
      VALUES (?, ?, ?, 'active', ?, ?, NOW())");
    $st->execute([$hotelId, $userId, $roomNo, $now->format('Y-m-d'), $outDT->format('Y-m-d')]);
    $hotelGuestId = (int)$pdo->lastInsertId();
  }

  $pdo->commit();

  out([
    'ok' => true,
    'loaded' => '_bootstrap.php',
    'hotel' => ['id' => $hotelId, 'name' => $hotelName, 'slug' => $hotelSlug],
    'user'  => ['id' => $userId, 'email' => $userMail],
    'stay_id' => $stayId,
    'hotel_guest_id' => $hotelGuestId
  ]);

} catch (Throwable $e) {
  if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack();
  out(['ok' => false, 'error' => 'exception', 'message' => $e->getMessage()], 500);
}

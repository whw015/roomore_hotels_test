<?php
require_once __DIR__ . '/../bootstrap.php';

try {
    $auth = require_auth();
    $userId = (int)$auth['user_id'];

    $pdo = db();
    $stmt = $pdo->prepare("
      SELECT s.id, s.hotel_id, h.name AS hotel_name, h.slug AS hotel_code,
             s.room_number, s.check_in, s.check_out, s.status
      FROM stays s
      JOIN hotels h ON h.id = s.hotel_id
      WHERE s.user_id = ?
      ORDER BY s.check_in DESC, s.id DESC
    ");
    $stmt->execute([$userId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    json_response(200, ['ok' => true, 'stays' => $rows]);
} catch (Throwable $e) {
    json_response(500, ['ok' => false, 'error' => 'server_error', 'message' => $e->getMessage()]);
}
<?php
require_once __DIR__ . '/../../_bootstrap.php';

/**
 * GET /public/stays/my.php
 * headers: Authorization: Bearer <JWT>
 * returns: { ok: true, stays: [ {id, hotel_id, hotel_name, hotel_code, room_number, check_in, check_out, status}, ... ] }
 */
try {
    $auth = require_auth(); // يُعيد ['user_id' => ...]
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
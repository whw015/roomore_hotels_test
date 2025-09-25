<?php
declare(strict_types=1);

// Bootstrap
$bootstrap = __DIR__ . '/../../_bootstrap.php';
if (!is_file($bootstrap)) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok'=>false,'error'=>'bootstrap_missing','hint'=>'Expected ../../_bootstrap.php from orders/'], JSON_UNESCAPED_UNICODE);
    exit;
}
require_once $bootstrap;

function send_json(int $status, array $payload): void {
    if (function_exists('json_response')) {
        json_response($status, $payload);
    } else {
        if (!headers_sent()) {
            http_response_code($status);
            header('Content-Type: application/json; charset=utf-8');
        }
        echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    }
    exit;
}
function get_token(): ?string {
    $h = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
    if (!$h && function_exists('apache_request_headers')) {
        foreach (apache_request_headers() as $k => $v) {
            if (strcasecmp($k, 'Authorization') === 0) { $h = $v; break; }
        }
    }
    if ($h && stripos($h, 'Bearer ') === 0) { $b = trim(substr($h, 7)); if ($b !== '') return $b; }
    if (!empty($_GET['token'])) return trim((string)$_GET['token']);
    $raw = file_get_contents('php://input');
    if ($raw) { $j = json_decode($raw, true);
        if (is_array($j) && !empty($j['token'])) return trim((string)$j['token']);
    }
    return null;
}
function resolve_user_via_me(): array {
    $token = get_token();
    if (!$token) send_json(401, ['ok'=>false,'error'=>'unauthorized','hint'=>'Missing Bearer token']);
    $ch = curl_init('https://brq25.com/roomore-api/api/auth/me.php');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Accept: application/json','Authorization: Bearer '.$token],
        CURLOPT_TIMEOUT => 12,
    ]);
    $out = curl_exec($ch);
    $err = curl_error($ch);
    $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    if ($err || $code !== 200) send_json(401, ['ok'=>false,'error'=>'unauthorized','hint'=>'auth/me failed','code'=>$code,'curl'=>$err]);
    $data = json_decode($out, true);
    if (!is_array($data) || !isset($data['user']['id'])) send_json(401, ['ok'=>false,'error'=>'unauthorized','hint'=>'me payload invalid']);
    return $data['user'];
}
function db_universal(): PDO {
    if (function_exists('db')) { $pdo = db(); if ($pdo instanceof PDO) return $pdo; }
    if (isset($GLOBALS['pdo']) && $GLOBALS['pdo'] instanceof PDO) return $GLOBALS['pdo'];
    if (isset($GLOBALS['db'])  && $GLOBALS['db']  instanceof PDO) return $GLOBALS['db'];
    if (function_exists('config')) {
        $cfg = config();
        if (is_array($cfg) && isset($cfg['db'])) {
            $d = $cfg['db'];
            $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $d['host'], $d['dbname']);
            return new PDO($dsn, $d['user'], $d['pass'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
        }
    }
    $cfgPath = __DIR__ . '/../../_config.php';
    if (is_file($cfgPath)) {
        $cfg = require $cfgPath;
        if (is_array($cfg) && isset($cfg['db'])) {
            $d = $cfg['db'];
            $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $d['host'], $d['dbname']);
            return new PDO($dsn, $d['user'], $d['pass'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
        }
        if (defined('DB_HOST') && defined('DB_NAME') && defined('DB_USER') && defined('DB_PASS')) {
            $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_NAME);
            return new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
        }
        if (isset($GLOBALS['pdo']) && $GLOBALS['pdo'] instanceof PDO) return $GLOBALS['pdo'];
        if (isset($GLOBALS['db'])  && $GLOBALS['db']  instanceof PDO) return $GLOBALS['db'];
    }
    send_json(500, ['ok'=>false,'error'=>'bootstrap_db_missing','hint'=>'No db()/pdo/config/db constants available in bootstrap/_config.php']);
    exit;
}

try {
    $user   = resolve_user_via_me();
    $userId = (int)$user['id'];

    $db = db_universal();

    $raw   = file_get_contents('php://input') ?: '';
    $input = json_decode($raw, true) ?: [];

    $hotelCode = isset($input['hotel_code']) ? trim((string)$input['hotel_code']) : '';
    $itemsIn   = isset($input['items']) && is_array($input['items']) ? $input['items'] : [];
    $notes     = isset($input['notes']) ? trim((string)$input['notes']) : null;

    if ($hotelCode === '') send_json(400, ['ok'=>false,'error'=>'hotel_code_required']);

    // فندق من hotels.slug
    $stmt = $db->prepare("SELECT id, name, slug FROM hotels WHERE slug = :slug LIMIT 1");
    $stmt->execute([':slug' => $hotelCode]);
    $hotel = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$hotel) send_json(404, ['ok'=>false,'error'=>'hotel_not_found']);
    $hotelId = (int)$hotel['id'];

    // عناصر [{id,qty}]
    $items = [];
    foreach ($itemsIn as $it) {
        $id  = isset($it['id']) ? (int)$it['id'] : 0;
        $qty = isset($it['qty']) ? (int)$it['qty'] : 0;
        if ($id > 0 && $qty > 0) $items[] = ['id'=>$id,'qty'=>$qty];
    }
    if (empty($items)) send_json(400, ['ok'=>false,'error'=>'no_items','hint'=>'Send items as [{id,qty}]']);

    // الأسعار من service_items.price
    $subtotal = 0.0;
    $getPrice = $db->prepare("SELECT id, name_en, name_ar, price FROM service_items WHERE id = :id LIMIT 1");
    foreach ($items as &$it) {
        $getPrice->execute([':id' => (int)$it['id']]);
        $row = $getPrice->fetch(PDO::FETCH_ASSOC);
        if (!$row) send_json(400, ['ok'=>false,'error'=>'item_not_found','item_id'=>$it['id']]);
        $it['price']   = (float)$row['price'];
        $it['name_en'] = (string)($row['name_en'] ?? '');
        $it['name_ar'] = (string)($row['name_ar'] ?? '');
        $subtotal += $it['price'] * (int)$it['qty'];
    }
    unset($it);

    $tax = 0.00;
    $total = $subtotal + $tax;

    $db->beginTransaction();

    // orders: subtotal/tax/total/currency
    $insOrder = $db->prepare(
        "INSERT INTO orders (user_id, hotel_id, stay_id, status, subtotal, tax, total, currency, notes, created_at)
         VALUES (:uid, :hid, NULL, 'pending', :subtotal, :tax, :total, 'SAR', :notes, NOW())"
    );
    $insOrder->execute([
        ':uid'=>$userId, ':hid'=>$hotelId,
        ':subtotal'=>$subtotal, ':tax'=>$tax, ':total'=>$total,
        ':notes'=>$notes,
    ]);
    $orderId = (int)$db->lastInsertId();

    // order_items
    $insItem = $db->prepare(
        "INSERT INTO order_items (order_id, item_id, name_en, name_ar, price, qty, line_total)
         VALUES (:oid, :iid, :nen, :nar, :price, :qty, :line)"
    );
    foreach ($items as $line) {
        $lineTotal = (float)$line['price'] * (int)$line['qty'];
        $insItem->execute([
            ':oid'=>$orderId,
            ':iid'=>(int)$line['id'],
            ':nen'=>(string)$line['name_en'],
            ':nar'=>(string)$line['name_ar'],
            ':price'=>(float)$line['price'],
            ':qty'=>(int)$line['qty'],
            ':line'=>$lineTotal,
        ]);
    }

    $db->commit();

    send_json(200, [
        'ok'=>true,
        'order_id'=>$orderId,
        'subtotal'=>$subtotal, 'tax'=>$tax, 'total'=>$total, 'currency'=>'SAR',
        'hotel'=>['id'=>$hotelId, 'name'=>$hotel['name'] ?? null, 'slug'=>$hotel['slug'] ?? $hotelCode],
    ]);
} catch (Throwable $e) {
    if (isset($db) && $db instanceof PDO && $db->inTransaction()) $db->rollBack();
    send_json(500, ['ok'=>false,'error'=>'exception','message'=>$e->getMessage()]);
}

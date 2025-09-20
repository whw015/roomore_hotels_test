<?php
declare(strict_types=1);

// 1) حمّل البوتستراب الأساسي للمشروع
$bootstrap = __DIR__ . '/../../_bootstrap.php';
if (!is_file($bootstrap)) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok'=>false,'error'=>'bootstrap_missing','hint'=>'Expected ../../_bootstrap.php from orders/'], JSON_UNESCAPED_UNICODE);
    exit;
}
require_once $bootstrap;

// 2) JSON helper (يفضّل json_response(status,payload) إن كانت موجودة)
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

// 3) استخراج الـ token من الهيدر / Query / Body
function get_token(): ?string {
    $h = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
    if (!$h && function_exists('apache_request_headers')) {
        foreach (apache_request_headers() as $k => $v) {
            if (strcasecmp($k, 'Authorization') === 0) { $h = $v; break; }
        }
    }
    if ($h && stripos($h, 'Bearer ') === 0) {
        $b = trim(substr($h, 7)); if ($b !== '') return $b;
    }
    if (!empty($_GET['token'])) return trim((string)$_GET['token']);
    $raw = file_get_contents('php://input');
    if ($raw) { $j = json_decode($raw, true);
        if (is_array($j) && !empty($j['token'])) return trim((string)$j['token']);
    }
    return null;
}

// 4) تحقق المستخدم عبر /api/auth/me.php
function resolve_user_via_me(): array {
    $token = get_token();
    if (!$token) send_json(401, ['ok'=>false,'error'=>'unauthorized','hint'=>'Missing Bearer token']);

    $ch = curl_init('https://brq25.com/roomore-api/api/auth/me.php');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Accept: application/json', 'Authorization: Bearer '.$token],
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

// 5) مُنشئ اتصال قاعدة بيانات شامل لكل السيناريوهات
function db_universal(): PDO {
    // أ) دالة db() من البوتستراب
    if (function_exists('db')) {
        $pdo = db();
        if ($pdo instanceof PDO) return $pdo;
    }
    // ب) متغيرات PDO عالمية
    if (isset($GLOBALS['pdo']) && $GLOBALS['pdo'] instanceof PDO) return $GLOBALS['pdo'];
    if (isset($GLOBALS['db'])  && $GLOBALS['db']  instanceof PDO) return $GLOBALS['db'];
    // ج) دالة config() تُعيد مصفوفة إعدادات
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
    // د) ثوابت معرفة في البوتستراب أو ملف إعدادات
    if (defined('DB_HOST') && defined('DB_NAME') && defined('DB_USER') && defined('DB_PASS')) {
        $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_NAME);
        return new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
    // هـ) محاولة قراءة _config.php ثم إعادة الفحص للثوابت/المصفوفة
    $cfgPath = __DIR__ . '/../../_config.php';
    if (is_file($cfgPath)) {
        $cfg = require $cfgPath; // بعض المشاريع تُعرّف ثوابت/تعيد array
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

// 6) المنطق
try {
    $user = resolve_user_via_me();
    $userId = (int)$user['id'];

    $db = db_universal();

    $status = isset($_GET['status']) ? trim((string)$_GET['status']) : null;

    $sql = "SELECT 
                o.id, o.hotel_id, o.status,
                o.subtotal, o.tax, o.total, o.currency, o.created_at,
                h.name AS hotel_name, h.slug AS hotel_slug
            FROM orders o
            INNER JOIN hotels h ON h.id = o.hotel_id
            WHERE o.user_id = :uid";
    $params = [':uid' => $userId];

    if ($status !== null && $status !== '') {
        $sql .= " AND o.status = :status";
        $params[':status'] = $status;
    }
    $sql .= " ORDER BY o.id DESC";

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];

    send_json(200, ['ok'=>true, 'orders'=>$orders]);
} catch (Throwable $e) {
    send_json(500, ['ok'=>false,'error'=>'exception','message'=>$e->getMessage()]);
}

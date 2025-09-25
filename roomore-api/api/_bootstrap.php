<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Authorization, Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }

// المسارات من داخل .../api/
require_once dirname(__FILE__) . '/../vendor/autoload.php';
$config = require dirname(__FILE__) . '/../config.php';
require_once dirname(__FILE__) . '/../db.php'; // يُنشئ $pdo
require_once __DIR__ . '/../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

function json_response($status, $data) {
  http_response_code($status);
  echo json_encode($data, JSON_UNESCAPED_UNICODE);
  exit;
}

function json_input() {
  $raw = file_get_contents('php://input');
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}

// التقاط Authorization من كل أشكالها على Apache/Nginx/CGI
function bearer_token() {
  $headers = function_exists('getallheaders') ? getallheaders() : [];
  $auth = isset($_SERVER['HTTP_AUTHORIZATION']) ? $_SERVER['HTTP_AUTHORIZATION'] : '';
  if (!$auth && isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) $auth = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
  if (!$auth && isset($headers['Authorization'])) $auth = $headers['Authorization'];
  if (!$auth && isset($headers['authorization'])) $auth = $headers['authorization'];
  if (preg_match('/Bearer\s+(.+)/i', $auth, $m)) return trim($m[1]);
  return null;
}

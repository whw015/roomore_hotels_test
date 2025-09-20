<?php
require_once dirname(__FILE__) . '/../bootstrap.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

function require_user_id() {
  global $config;
  $token = bearer_token();
  if (!$token) { json_response(401, ['error' => 'Missing bearer token']); }
  try {
    $payload = JWT::decode($token, new Key($config['jwt_secret'], 'HS256'));
  } catch (Exception $e) {
    json_response(401, ['error' => 'Bad token']);
  }
  if (!isset($payload->sub)) { json_response(401, ['error' => 'Invalid token']); }
  return (int)$payload->sub;
}

function ensure_open_cart($userId) {
  global $pdo;
  $stmt = $pdo->prepare("SELECT id FROM carts WHERE user_id=? AND status='open' LIMIT 1");
  $stmt->execute([$userId]);
  $cart = $stmt->fetch();
  if ($cart) return (int)$cart['id'];
  $pdo->prepare("INSERT INTO carts (user_id, status) VALUES (?, 'open')")->execute([$userId]);
  return (int)$pdo->lastInsertId();
}

function item_fields_for_lang($lang) {
  return ($lang === 'ar')
    ? "si.name_ar AS name, si.description_ar AS description"
    : "si.name_en AS name, si.description_en AS description";
}
<?php
require_once __DIR__ . '/_bootstrap.php';

function resolve_hotel_by_code($code) {
  global $pdo;
  if (!$code) return null;
  $stmt = $pdo->prepare("SELECT id, name, slug, city FROM hotels WHERE slug = ? LIMIT 1");
  $stmt->execute([$code]);
  $hotel = $stmt->fetch();
  return $hotel ?: null;
}

function require_hotel($code) {
  $hotel = resolve_hotel_by_code($code);
  if (!$hotel) {
    json_response(404, ['error' => 'Hotel not found', 'code' => $code]);
  }
  return $hotel;
}
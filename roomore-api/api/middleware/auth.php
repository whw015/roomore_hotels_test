<?php
declare(strict_types=1);
function require_bearer(): ?int {
  $hdr = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
  if (!preg_match('/Bearer\s+(.+)/', $hdr, $m)) return null;
  $token = $m[1];
  return 1;
}
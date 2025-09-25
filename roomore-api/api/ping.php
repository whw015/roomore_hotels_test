<?php
header('Content-Type: application/json; charset=utf-8');
echo json_encode(['pong' => true, 'time' => time()]);

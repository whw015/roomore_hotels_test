<?php
header('Content-Type: application/json');
$conn = new mysqli('localhost', 'username', 'password', 'fjgbsgmy_roomoreDB');
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed']));
}
$data = $_POST;
$stmt = $conn->prepare("DELETE FROM work_groups WHERE id = ?");
$stmt->bind_param("s", $data['id']);
$stmt->execute();
echo json_encode(['success' => true]);
$stmt->close();
$conn->close();
?>
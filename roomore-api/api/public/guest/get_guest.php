<?php
header('Content-Type: application/json');
$conn = new mysqli('localhost', 'username', 'password', 'fjgbsgmy_roomoreDB');
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed']));
}
$result = $conn->query("SELECT * FROM guest");
$employees = [];
while ($row = $result->fetch_assoc()) {
    $employees[] = $row;
}
echo json_encode(['employees' => $employees]);
$conn->close();
?>
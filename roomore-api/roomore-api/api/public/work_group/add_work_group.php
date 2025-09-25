<?php
header('Content-Type: application/json');
$conn = new mysqli('localhost', 'username', 'password', 'fjgbsgmy_roomoreDB');
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed']));
}
$data = json_decode(file_get_contents('php://input'), true);
$stmt = $conn->prepare("INSERT INTO work_group (name, email, phone, gender, nationality, dob, id_number, job_title, employee_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sssssssss", $data['name'], $data['email'], $data['phone'], $data['gender'], $data['nationality'], $data['dob'], $data['id_number'], $data['job_title'], $data['employee_id']);
$stmt->execute();
echo json_encode(['success' => true]);
$stmt->close();
$conn->close();
?>
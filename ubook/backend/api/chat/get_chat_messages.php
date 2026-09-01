<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

// Verificar si los parámetros necesarios están presentes
if (!isset($_GET['uid']) || !isset($_GET['partnerId'])) {
    echo json_encode(['error' => 'Missing parameters']);
    http_response_code(400); // Bad Request
    exit;
}

$uid = $_GET['uid'];
$partnerId = $_GET['partnerId'];

// Validar si los valores son enteros positivos
if (!is_numeric($uid) || !is_numeric($partnerId) || $uid <= 0 || $partnerId <= 0) {
    echo json_encode(['error' => 'Invalid parameters']);
    http_response_code(400); // Bad Request
    exit;
}

$sql = "SELECT message_id, message, sender_id, receiver_id, timestamp, is_seenmessages
        FROM messages
        WHERE (sender_id = ? AND receiver_id = ?)
        OR (sender_id = ? AND receiver_id = ?)
        ORDER BY timestamp ASC";

$stmt = $conn->prepare($sql);

// Verificar si la consulta se preparó correctamente
if (!$stmt) {
    echo json_encode(['error' => 'Database error']);
    http_response_code(500); // Internal Server Error
    exit;
}

$stmt->bind_param("iiii", $uid, $partnerId, $partnerId, $uid);
$stmt->execute();
$result = $stmt->get_result();

$messages = [];
while ($row = $result->fetch_assoc()) {
    $messages[] = $row;
}

// Verificar si hay mensajes
if (empty($messages)) {
    echo json_encode(['message' => 'No messages found']);
    http_response_code(404); // Not Found
    exit;
}

echo json_encode($messages);

$stmt->close();
$conn->close();
?>

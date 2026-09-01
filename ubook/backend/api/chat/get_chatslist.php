<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$uid = $_GET['uid']; // obtener el uid desde el parámetro de consulta

$query = "SELECT * FROM chatlist WHERE user_id = ? OR chat_partner_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $uid, $uid);  // Usa "ii" ya que estás pasando enteros (IDs)
$stmt->execute();
$result = $stmt->get_result();

$chats = [];
while ($row = $result->fetch_assoc()) {
    $chats[] = $row;
}

echo json_encode($chats);  // Devuelve los chats en formato JSON
$stmt->close();
$conn->close();
?>

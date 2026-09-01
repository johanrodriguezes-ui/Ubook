<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$user_id = $_POST['user_id'];
$chat_partner_id = $_POST['chat_partner_id'];
$last_message = $_POST['last_message'];

// Verificar si el chat ya existe en la tabla chatlist
$query_check = "SELECT * FROM chatlist WHERE (user_id = ? AND chat_partner_id = ?) OR (user_id = ? AND chat_partner_id = ?)";
$stmt_check = $conn->prepare($query_check);
$stmt_check->bind_param("iiii", $user_id, $chat_partner_id, $chat_partner_id, $user_id);
$stmt_check->execute();
$result = $stmt_check->get_result();

if ($result->num_rows > 0) {
    // El chat ya existe, actualizar el last_message y timestamp
    $query_update = "UPDATE chatlist SET last_message = ?, timestamp = NOW() WHERE (user_id = ? AND chat_partner_id = ?) OR (user_id = ? AND chat_partner_id = ?)";
    $stmt_update = $conn->prepare($query_update);
    $stmt_update->bind_param("siiii", $last_message, $user_id, $chat_partner_id, $chat_partner_id, $user_id);

    if ($stmt_update->execute()) {
        echo json_encode(['status' => 'updated', 'message' => 'Chat actualizado exitosamente']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No se pudo actualizar el chat']);
    }

    $stmt_update->close();
} else {
    // Si no existe, inserta el chat
    $query_insert = "INSERT INTO chatlist (user_id, chat_partner_id, last_message, timestamp) VALUES (?, ?, ?, NOW())";
    $stmt_insert = $conn->prepare($query_insert);
    $stmt_insert->bind_param("iis", $user_id, $chat_partner_id, $last_message);

    if ($stmt_insert->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Chat creado exitosamente']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No se pudo insertar el chat']);
    }
    
    $stmt_insert->close();
}

$stmt_check->close();
$conn->close();
?>

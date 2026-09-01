<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Decodificar datos JSON
    $data = json_decode(file_get_contents('php://input'), true);
    $messageId = $data['message_id'];
    $newMessage = $data['message'];

    // Validar que se hayan proporcionado el ID y el nuevo mensaje
    if (empty($messageId) || empty($newMessage)) {
        echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
        exit;
    }

    // Actualizar el mensaje en la base de datos
    $query = "UPDATE groupmessages SET message = ? WHERE idgroupmessages = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("si", $newMessage, $messageId);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Mensaje actualizado correctamente']);
    } else {
        error_log("SQL Error: " . $stmt->error); // Log el error SQL
        echo json_encode(['status' => 'error', 'message' => 'Error al actualizar el mensaje']);
    }

    $stmt->close();
    $conn->close();
}

?>


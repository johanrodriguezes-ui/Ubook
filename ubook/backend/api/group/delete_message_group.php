<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Decodificar datos JSON
    $data = json_decode(file_get_contents('php://input'), true);
    $messageId = $data['message_id'];

    // Imprimir el valor de message_id en el log del servidor
    error_log("El valor de message_id es: " . $messageId);

    // Validar que se haya proporcionado un ID de mensaje
    if (empty($messageId)) {
        echo json_encode(['status' => 'error', 'message' => 'ID del mensaje no proporcionado']);
        exit;
    }

    // Eliminar el mensaje de la base de datos
    $query = "DELETE FROM groupmessages WHERE idgroupmessages = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $messageId);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Mensaje eliminado correctamente']);
    } else {
        error_log("SQL Error: " . $stmt->error); // Log el error SQL
        echo json_encode(['status' => 'error', 'message' => 'Error al eliminar el mensaje']);
    }

    $stmt->close();
    $conn->close();
}


?>

<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Decodificar el cuerpo JSON de la solicitud
    $data = json_decode(file_get_contents("php://input"), true);

    $groupId = $data['group_id'] ?? null;
    $senderId = $data['sender_id'] ?? null;
    $message = $data['message'] ?? null;
    $url = $data['url'] ?? '';

    // Verificar si los datos fueron enviados correctamente
    if (empty($groupId) || empty($senderId) || empty($message)) {
        echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
        exit;
    }

    // Iniciar una transacción para asegurar que ambas operaciones (inserción y actualización) se ejecuten juntas
    $conn->begin_transaction();

    try {
        // Enviar el mensaje
        $query = "INSERT INTO groupmessages (group_id, sender_id, message, url) VALUES (?, ?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("iiss", $groupId, $senderId, $message, $url);

        if ($stmt->execute()) {
            // Actualizar el campo 'lastmessage' en la tabla 'groups'
            $updateQuery = "UPDATE groups SET lastmessage = ? WHERE group_id = ?";
            $updateStmt = $conn->prepare($updateQuery);
            $updateStmt->bind_param("si", $message, $groupId);

            if ($updateStmt->execute()) {
                // Confirmar la transacción
                $conn->commit();
                echo json_encode(['status' => 'success']);
            } else {
                // Revertir la transacción en caso de error
                $conn->rollback();
                echo json_encode(['status' => 'error', 'message' => 'Error al actualizar el último mensaje']);
            }

            $updateStmt->close();
        } else {
            // Revertir la transacción en caso de error
            $conn->rollback();
            echo json_encode(['status' => 'error', 'message' => 'Error al enviar el mensaje']);
        }

        $stmt->close();
    } catch (Exception $e) {
        // Manejar cualquier excepción y revertir la transacción
        $conn->rollback();
        echo json_encode(['status' => 'error', 'message' => 'Excepción: ' . $e->getMessage()]);
    }

    $conn->close();
}
?>

<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$message_id = $_POST['message_id'] ?? null;

if ($message_id) {
    // Obtener el chat y el id del receptor y remitente de este mensaje antes de eliminarlo
    $query_message = "SELECT sender_id, receiver_id FROM messages WHERE message_id = ?";
    $stmt_message = $conn->prepare($query_message);
    $stmt_message->bind_param("i", $message_id);
    $stmt_message->execute();
    $result_message = $stmt_message->get_result();
    $message_data = $result_message->fetch_assoc();

    if ($message_data) {
        $sender_id = $message_data['sender_id'];
        $receiver_id = $message_data['receiver_id'];

        // Eliminar el mensaje
        $query_delete = "DELETE FROM messages WHERE message_id = ?";
        $stmt_delete = $conn->prepare($query_delete);
        $stmt_delete->bind_param("i", $message_id);

        if ($stmt_delete->execute()) {
            // Verificar si quedan más mensajes en el chat
            $query_check = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY timestamp DESC LIMIT 1";
            $stmt_check = $conn->prepare($query_check);
            $stmt_check->bind_param("iiii", $sender_id, $receiver_id, $receiver_id, $sender_id);
            $stmt_check->execute();
            $result_check = $stmt_check->get_result();

            if ($result_check->num_rows > 0) {
                // Si queda al menos un mensaje, actualizar el último mensaje en chatlist
                $last_message = $result_check->fetch_assoc();
                $query_update_chatlist = "UPDATE chatlist SET last_message = ?, timestamp = NOW() WHERE (user_id = ? AND chat_partner_id = ?) OR (user_id = ? AND chat_partner_id = ?)";
                $stmt_update = $conn->prepare($query_update_chatlist);
                $stmt_update->bind_param("siiii", $last_message['message'], $sender_id, $receiver_id, $receiver_id, $sender_id);
                $stmt_update->execute();
            } else {
                // Si no quedan más mensajes, eliminar el chat de chatlist
                $query_delete_chat = "DELETE FROM chatlist WHERE (user_id = ? AND chat_partner_id = ?) OR (user_id = ? AND chat_partner_id = ?)";
                $stmt_delete_chat = $conn->prepare($query_delete_chat);
                $stmt_delete_chat->bind_param("iiii", $sender_id, $receiver_id, $receiver_id, $sender_id);
                $stmt_delete_chat->execute();
            }

            echo json_encode(['status' => 'success', 'message' => 'Mensaje eliminado y chat actualizado']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error al eliminar el mensaje']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Mensaje no encontrado']);
    }

    $stmt_message->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
}

$conn->close();
?>
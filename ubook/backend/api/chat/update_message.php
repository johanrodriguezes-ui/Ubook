<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
include '../db.php';
// Obtener datos del mensaje
$message_id = $_POST['message_id'] ?? null; // El id del mensaje que se va a actualizar
$new_message = $_POST['new_message'] ?? null; // El nuevo mensaje
// Comprobar si ambos datos están presentes
if ($message_id && $new_message) {
    // Obtener el chat y el id del receptor y remitente de este mensaje
    $query_message = "SELECT sender_id, receiver_id FROM messages WHERE message_id = ?";
    $stmt_message = $conn->prepare($query_message);
    $stmt_message->bind_param("i", $message_id);
    $stmt_message->execute();
    $result_message = $stmt_message->get_result();
    $message_data = $result_message->fetch_assoc();
    if ($message_data) {
        $sender_id = $message_data['sender_id'];
        $receiver_id = $message_data['receiver_id'];
        // Actualizar el mensaje
        $query_update = "UPDATE messages SET message = ? WHERE message_id = ?";
        $stmt_update = $conn->prepare($query_update);
        $stmt_update->bind_param("si", $new_message, $message_id);
        if ($stmt_update->execute()) {
            // Verificar si el mensaje actualizado era el último en el chat
            $query_check = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY timestamp DESC LIMIT 1";
            $stmt_check = $conn->prepare($query_check);
            $stmt_check->bind_param("iiii", $sender_id, $receiver_id, $receiver_id, $sender_id);
            $stmt_check->execute();
            $result_check = $stmt_check->get_result();
            if ($result_check->num_rows > 0) {
                // Si queda al menos un mensaje, actualizar el último mensaje en chatlist
                $last_message = $result_check->fetch_assoc();
                $query_update_chatlist = "UPDATE chatlist SET last_message = ?, timestamp = NOW() WHERE (user_id = ? AND chat_partner_id = ?) OR (user_id = ? AND chat_partner_id = ?)";
                $stmt_update_chatlist = $conn->prepare($query_update_chatlist);
                $stmt_update_chatlist->bind_param("siiii", $last_message['message'], $sender_id, $receiver_id, $receiver_id, $sender_id);
                $stmt_update_chatlist->execute();
            } 
            echo json_encode(['status' => 'success', 'message' => 'Mensaje actualizado correctamente']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error al actualizar el mensaje']);
        }
        $stmt_update->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Mensaje no encontrado']);
    }
    $stmt_message->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
}
$conn->close();
?>

<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Asegurarse de que los nombres de los campos sean consistentes
    $sender_id = $_POST['sender_id'] ?? null;
    $receiver_id = $_POST['receiver_id'] ?? null;
    $message = $_POST['message'] ?? null;
    $is_seenmessages = 0; // Marcado por defecto como no visto
    $url = $_POST['url'] ?? null; // URL opcional

    if ($sender_id && $receiver_id && $message) {
        // Insertar el mensaje en la base de datos
        $sql = "INSERT INTO messages (sender_id, receiver_id, message, is_seenmessages, url) VALUES (?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iisis", $sender_id, $receiver_id, $message, $is_seenmessages, $url);

        if ($stmt->execute()) {
            echo json_encode(array("status" => "success"));
        } else {
            echo json_encode(array("status" => "error", "message" => $stmt->error));
        }

        $stmt->close();
    } else {
        echo json_encode(array("status" => "error", "message" => "Datos incompletos o inválidos"));
    }

    $conn->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Método no permitido"));
}
?>

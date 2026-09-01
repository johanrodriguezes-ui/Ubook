<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = $_POST['user_id'];
    $content = $_POST['content'];

    if (!empty($user_id) && !empty($content)) {
        $sql = "INSERT INTO posts (user_id, content, likes, post_date) VALUES ('$user_id', '$content', 0, NOW())";
        if ($conn->query($sql) === TRUE) {

            $users_query = "SELECT uid FROM dateperson"; // Asumiendo que tienes una tabla de usuarios
            $users_result = mysqli_query($conn, $users_query);
            
            // Añadir una notificación para cada usuario
            while ($row = mysqli_fetch_assoc($users_result)) {
                $user_id_for_notification = $row['uid'];
                $title = "Nuevo post añadido";
                $message = "Un usuario ha publicado: $content";
                $created_at = date('Y-m-d H:i:s');
                
                $notification_query = "INSERT INTO notifications (user_id, title, message, is_read, created_at)
                                    VALUES ('$user_id_for_notification', '$title', '$message', 0, '$created_at')";
                mysqli_query($conn, $notification_query);
            }

            echo json_encode(["success" => true, "message" => "Publicación añadida exitosamente."]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al añadir publicación."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Faltan datos necesarios."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Método no permitido."]);
}

$conn->close();
?>

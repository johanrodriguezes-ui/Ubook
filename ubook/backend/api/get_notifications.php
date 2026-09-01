<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

include 'db.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $user_id = $_GET['user_id'];

    // Validar que el ID de usuario no esté vacío
    if (!empty($user_id)) {
        // Consulta para obtener las notificaciones del usuario
        $sql = "SELECT id, title, message, is_read, created_at FROM notifications WHERE user_id = '$user_id' ORDER BY created_at DESC";
        $result = mysqli_query($conn, $sql);

        if ($result) {
            $notifications = [];

            while ($row = mysqli_fetch_assoc($result)) {
                $notifications[] = $row;
            }

            // Devolver las notificaciones en formato JSON
            echo json_encode($notifications);
        } else {
            echo json_encode(['error' => 'Error al obtener las notificaciones.']);
        }
    } else {
        echo json_encode(['error' => 'ID de usuario no proporcionado.']);
    }
} else {
    echo json_encode(['error' => 'Método no permitido.']);
}

$conn->close();
?>

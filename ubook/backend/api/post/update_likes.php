<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

// Actualizar likes
if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    parse_str(file_get_contents("php://input"), $_PUT);
    $post_id = intval($_PUT['post_id'] ?? null);
    $action = $_PUT['action'] ?? null; // 'like' o 'unlike'

    if ($post_id && $action) {
        // Preparar la consulta según la acción (like o unlike)
        if ($action == 'like') {
            $stmt = mysqli_prepare($conn, "UPDATE posts SET likes = likes + 1 WHERE post_id = ?");
        } else {
            $stmt = mysqli_prepare($conn, "UPDATE posts SET likes = likes - 1 WHERE post_id = ?");
        }

        // Vincular el parámetro de post_id como entero
        mysqli_stmt_bind_param($stmt, "i", $post_id);
        mysqli_stmt_execute($stmt);

        // Verificar si la consulta afectó alguna fila
        if (mysqli_stmt_affected_rows($stmt) > 0) {
            // Obtener el número actualizado de likes después del cambio
            $result = mysqli_query($conn, "SELECT likes FROM posts WHERE post_id = $post_id");
            $row = mysqli_fetch_assoc($result);
            $updatedLikes = $row['likes'];

            // Devolver los likes actualizados en formato JSON
            echo json_encode([
                'message' => 'Like actualizado',
                'likes' => $updatedLikes
            ]);
        } else {
            echo json_encode(['message' => 'No se encontró el post o no se realizaron cambios.']);
        }

        mysqli_stmt_close($stmt);
    } else {
        echo json_encode(['message' => 'Datos incompletos']);
    }
}

$conn->close();
?>

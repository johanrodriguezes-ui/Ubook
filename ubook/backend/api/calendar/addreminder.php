<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = $_POST['user_id'];
    $reminder_message = $_POST['reminder_message'];
    $reminder_date = $_POST['reminder_date'];

    if (!empty($user_id) && !empty($reminder_message) && !empty($reminder_date)) {
        // Insertar el recordatorio en la tabla del calendario
        $query = "INSERT INTO calendar (user_id, reminder_message, reminder_date) VALUES ('$user_id', '$reminder_message', '$reminder_date')";
        if (mysqli_query($conn, $query)) {
            
            // Obtener todos los usuarios
            $users_query = "SELECT uid FROM dateperson"; // Asumiendo que tienes una tabla de usuarios
            $users_result = mysqli_query($conn, $users_query);
            
            // Añadir una notificación para cada usuario
            while ($row = mysqli_fetch_assoc($users_result)) {
                $user_id_for_notification = $row['uid'];
                $title = "Nuevo recordatorio añadido";
                $message = "Un usuario ha añadido un recordatorio: $reminder_message en la fecha: $reminder_date";
                $created_at = date('Y-m-d');
                
                $notification_query = "INSERT INTO notifications (user_id, title, message, is_read, created_at)
                                       VALUES ('$user_id_for_notification', '$title', '$message', 0, '$created_at')";
                mysqli_query($conn, $notification_query);
            }

            echo json_encode(['status' => 'success', 'message' => 'Recordatorio añadido exitosamente.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error al añadir el recordatorio.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Faltan datos necesarios.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Método no permitido.']);
}

$conn->close();
?>

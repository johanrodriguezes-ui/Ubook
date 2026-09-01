<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include '../db.php'; 

// Captura los datos enviados por POST
$user_id = $_POST['user_id'];
$reminder_date = $_POST['reminder_date']; // Obtener la fecha seleccionada

// Verifica que las variables no estén vacías antes de proceder
if (isset($user_id) && isset($reminder_date)) {
    // Prepara la consulta SQL
    $query = "SELECT reminder_id, reminder_message, reminder_date 
              FROM calendar 
              WHERE user_id = ? AND reminder_date = ?";
    
    // Prepara la consulta usando prepared statements para evitar inyecciones SQL
    if ($stmt = $conn->prepare($query)) {
        $stmt->bind_param("is", $user_id, $reminder_date); // "i" para integer, "s" para string

        // Ejecuta la consulta
        $stmt->execute();

        // Obtiene el resultado
        $result = $stmt->get_result();
        $reminders = [];

        // Procesa los resultados
        while ($row = $result->fetch_assoc()) {
            $reminders[] = $row;
        }

        // Devuelve la respuesta en formato JSON
        echo json_encode($reminders);
    } else {
        // Error en la preparación de la consulta
        echo json_encode(['error' => 'Error en la preparación de la consulta']);
    }
} else {
    // Error si faltan parámetros
    echo json_encode(['error' => 'Faltan parámetros']);
}
?>

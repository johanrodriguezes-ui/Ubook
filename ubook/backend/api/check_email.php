<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Establecer el tipo de contenido de la respuesta a JSON
header('Content-Type: application/json');

// Conexión a la base de datos
$conn = new mysqli('localhost', 'root', '', 'ubook');

// Verificar si la conexión fue exitosa
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Error de conexión: " . $conn->connect_error]));
}

// Verificar si es una solicitud POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Verificar que el campo 'email' esté presente en la solicitud
    if (isset($_POST['email'])) {
        $email = $_POST['email'];

        // Preparar la consulta SQL
        $stmt = $conn->prepare("SELECT * FROM dateperson WHERE email = ?");
        $stmt->bind_param("s", $email);
        
        // Ejecutar la consulta
        $stmt->execute();
        $result = $stmt->get_result();

        // Verificar si se encontraron resultados
        if ($result->num_rows > 0) {
            echo json_encode(['exists' => true, 'message' => 'El correo electrónico ya está registrado.']);
        } else {
            echo json_encode(['exists' => false, 'message' => 'El correo electrónico no está registrado.']);
        }

        // Cerrar la sentencia y la conexión
        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'El campo email es obligatorio.']);
    }
}

// Cerrar la conexión
$conn->close();
?>
<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Incluir el archivo de conexión a la base de datos
include '../db.php';

// Verificar si la solicitud es de tipo POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Obtener los datos del cuerpo de la solicitud (community_id y group_id)
    $data = json_decode(file_get_contents("php://input"), true);

    // Verificar si los parámetros necesarios están presentes
    if (isset($data['community_id']) && isset($data['group_id'])) {
        $community_id = $data['community_id'];
        $group_id = $data['group_id'];

        // Preparar la consulta para insertar en community_groups
        $query = "INSERT INTO community_groups (community_id, group_id) VALUES (?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ii", $community_id, $group_id); // 'ii' porque son enteros

        // Ejecutar la consulta y verificar si fue exitosa
        if ($stmt->execute()) {
            // Responder con éxito
            $response = array("status" => "success", "message" => "Group added to community successfully.");
        } else {
            // Responder con error si la consulta falla
            $response = array("status" => "error", "message" => "Failed to add group to community.");
        }

        // Cerrar la consulta
        $stmt->close();
    } else {
        // Responder con error si faltan parámetros
        $response = array("status" => "error", "message" => "Missing community_id or group_id.");
    }
} else {
    // Responder con error si el método no es POST
    $response = array("status" => "error", "message" => "Invalid request method.");
}

// Retornar la respuesta en formato JSON
echo json_encode($response);

// Cerrar la conexión
$conn->close();
?>

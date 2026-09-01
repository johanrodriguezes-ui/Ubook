<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $groupId = $_POST['group_id'];
    $userId = $_POST['user_id'];

    // Verificar si los datos fueron enviados correctamente
    if (empty($groupId) || empty($userId)) {
        echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
        exit;
    }

    // Añadir miembro al grupo
    $query = "INSERT INTO groupmembers (group_id, user_id) VALUES (?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ii", $groupId, $userId);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error al añadir miembro']);
    }
    
    $stmt->close();
    $conn->close();
}
?>

<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php'; 

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $groupName = $_POST['group_name'];
    $groupImage = $_POST['group_image'];
    $createdBy = $_POST['created_by'];
    $initialMessage = $_POST['initial_message']; // Nuevo campo para el mensaje inicial

    // Verificar si los datos fueron enviados correctamente
    if (empty($groupName) || empty($createdBy) || empty($initialMessage)) {
        echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
        exit;
    }

    // Crear el grupo y añadir el mensaje inicial en la columna lastmessage
    $query = "INSERT INTO groups (group_name, group_image, created_by, lastmessage) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ssis", $groupName, $groupImage, $createdBy, $initialMessage);

    if ($stmt->execute()) {
        // Obtener el ID del grupo recién creado
        $groupId = $stmt->insert_id;

        // Añadir al creador como miembro del grupo
        $query2 = "INSERT INTO groupmembers (group_id, user_id) VALUES (?, ?)";
        $stmt2 = $conn->prepare($query2);
        $stmt2->bind_param("ii", $groupId, $createdBy);
        if ($stmt2->execute()) {
            echo json_encode(['status' => 'success', 'group_id' => $groupId]);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error al añadir miembro']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error al crear el grupo']);
    }

    $stmt->close();
    $conn->close();
}
?>

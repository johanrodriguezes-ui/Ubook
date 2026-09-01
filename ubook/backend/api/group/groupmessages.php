<?php 
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $groupId = $_GET['group_id'];

    // Verificar si el grupo ID fue enviado
    if (empty($groupId)) {
        echo json_encode(['status' => 'error', 'message' => 'ID del grupo no proporcionado']);
        exit;
    }

    // Obtener mensajes del grupo usando 'idgroupmessages' en lugar de 'message_id'
    $query = "SELECT gm.idgroupmessages AS message_id, gm.message, gm.url, gm.timestamp, gm.sender_id, dp.name AS senderName 
    FROM groupmessages gm 
    JOIN dateperson dp ON gm.sender_id = dp.uid 
    WHERE gm.group_id = ? 
    ORDER BY gm.timestamp ASC";

    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $groupId);
    $stmt->execute();
    
    $result = $stmt->get_result();
    $messages = [];

    while ($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }

    echo json_encode($messages);
    
    $stmt->close();
    $conn->close();
}
?>

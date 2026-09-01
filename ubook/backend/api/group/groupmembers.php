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

    // Obtener miembros del grupo usando 'user_id' en lugar de 'member_id'
    $query = "SELECT dp.uid, dp.name 
              FROM groupmembers gm 
              JOIN dateperson dp ON gm.user_id = dp.uid 
              WHERE gm.group_id = ?";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $groupId);
    $stmt->execute();
    
    $result = $stmt->get_result();
    $members = [];

    while ($row = $result->fetch_assoc()) {
        $members[] = $row;
    }

    echo json_encode($members);
    
    $stmt->close();
    $conn->close();
}
?>

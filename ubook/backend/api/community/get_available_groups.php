<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$community_id = $_GET['community_id'];

if (isset($community_id)) {
    // Consultar grupos que no están asociados con la comunidad actual
    $query = "SELECT * FROM groups 
              WHERE group_id NOT IN (SELECT group_id FROM community_groups WHERE community_id = ?)";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $community_id);
    $stmt->execute();
    
    $result = $stmt->get_result();
    $groups = [];

    while ($row = $result->fetch_assoc()) {
        $groups[] = $row;
    }

    echo json_encode($groups);
} else {
    echo json_encode(['error' => 'Faltan parámetros']);
}

?>

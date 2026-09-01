<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$community_id = $_GET['community_id'];
$uid = $_GET['uid'];

if (!$community_id || !$uid) {
    echo json_encode([]);
    exit();
}

try {
    // Consulta para obtener usuarios que no están en la comunidad
    $sql = "SELECT dp.uid, dp.name, dp.email 
            FROM dateperson dp 
            WHERE dp.uid NOT IN (
                SELECT cm.user_id 
                FROM community_members cm 
                WHERE cm.community_id = ?
            ) AND dp.uid != ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $community_id, $uid);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
    
    echo json_encode($users);

} catch (Exception $e) {
    echo json_encode([]);
}
?>

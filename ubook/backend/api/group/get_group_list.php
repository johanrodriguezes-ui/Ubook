<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$uid = $_GET['uid'];

if (isset($uid)) {
    // Consulta para obtener los grupos en los que el usuario participa
    $query = "SELECT g.group_id, g.group_name, g.group_image, g.lastmessage, gm.user_id, g.created_by 
    FROM groups g 
    INNER JOIN groupmembers gm ON g.group_id = gm.group_id 
    WHERE gm.user_id = ?";

              
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $uid);
    $stmt->execute();
    $result = $stmt->get_result();

    $groups = array();
    while ($row = $result->fetch_assoc()) {
        $groups[] = $row;
    }

    echo json_encode($groups);
} else {
    echo json_encode(array("status" => "error", "message" => "No se proporcionó UID"));
}
?>

<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$user_id = $_GET['uid'];

$query = "SELECT * FROM communities WHERE created_by = ? OR community_id IN (SELECT community_id FROM community_members WHERE user_id = ?)";
$stmt = $conn->prepare($query);
$stmt->bind_param("ss", $user_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

$communities = array();

while ($row = $result->fetch_assoc()) {
    $communities[] = array(
        'community_id' => $row['community_id'],
        'community_name' => $row['community_name'],
        'community_image' => $row['community_image'],
        'created_by' => $row['created_by']
    );
}

echo json_encode($communities);
?>

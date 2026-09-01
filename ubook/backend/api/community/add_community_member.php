<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

$community_id = $_POST['community_id'];
$user_id = $_POST['user_id'];

if (!$community_id || !$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit();
}

try {
    // Inserta el nuevo miembro en la comunidad
    $sql = "INSERT INTO community_members (community_id, user_id, joined_at) VALUES (?, ?, NOW())";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $community_id, $user_id);
    
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to add member']);
    }

} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Error: ' . $e->getMessage()]);
}
?>

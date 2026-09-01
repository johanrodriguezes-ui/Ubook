<?php 
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php'; // Asegúrate de que este archivo contiene la conexión a la base de datos

$community_id = $_GET['community_id'];

$query = "SELECT dateperson.uid AS user_id, dateperson.name AS user_name, dateperson.profile AS user_image 
          FROM community_members 
          JOIN dateperson ON community_members.user_id = dateperson.uid 
          WHERE community_members.community_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $community_id);
$stmt->execute();
$result = $stmt->get_result();

$members = array();

while ($row = $result->fetch_assoc()) {
    $members[] = array(
        'user_id' => $row['user_id'],
        'user_name' => $row['user_name'],
        'user_image' => $row['user_image']
    );
}

echo json_encode($members);
?>

<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

// Obtener el community_id desde los parámetros GET
$community_id = $_GET['community_id'];

$query = "SELECT community_groups.community_group_id, groups.group_id, groups.group_name, groups.group_image, groups.lastmessage, groups.created_by 
          FROM community_groups 
          JOIN groups ON community_groups.group_id = groups.group_id 
          WHERE community_groups.community_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $community_id); // 'i' porque es un entero (int)
$stmt->execute();
$result = $stmt->get_result();

$groups = array();

while ($row = $result->fetch_assoc()) {
    $groups[] = array(
        'community_group_id' => $row['community_group_id'],
        'group_id' => $row['group_id'], // Agregar el ID del grupo
        'group_name' => $row['group_name'],
        'group_image' => $row['group_image'], // Este campo es opcional, puede ser NULL
        'lastmessage' => $row['lastmessage'],
        'created_by' => $row['created_by'] // Agregar el ID del creador del grupo
    );
}

// Retornar los datos en formato JSON
echo json_encode($groups);
?>

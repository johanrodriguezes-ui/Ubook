<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

// Verifica si 'uid' y 'group_id' han sido pasados como parámetros
if (!isset($_GET['uid']) || !isset($_GET['group_id'])) {
    echo json_encode(["error" => "Los parámetros 'uid' y 'group_id' son requeridos"]);
    exit;
}

$uid = $_GET['uid'];
$group_id = $_GET['group_id'];

// Consulta para traer todos los usuarios excepto el usuario actual y aquellos que ya son miembros del grupo
$sql = "SELECT uid, name
        FROM dateperson
        WHERE uid != ? AND uid NOT IN (
            SELECT user_id FROM groupmembers WHERE group_id = ?
        )";

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    echo json_encode(["error" => "Error al preparar la consulta"]);
    exit;
}

$stmt->bind_param("ii", $uid, $group_id);

if (!$stmt->execute()) {
    echo json_encode(["error" => "Error al ejecutar la consulta"]);
    exit;
}

$result = $stmt->get_result();

$users = [];
while ($row = $result->fetch_assoc()) {
    $users[] = $row;
}

echo json_encode($users);
?>

<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

// Verifica si 'uid' ha sido pasado como parámetro
if (!isset($_GET['uid'])) {
    echo json_encode(["error" => "El parámetro 'uid' es requerido"]);
    exit;
}

$uid = $_GET['uid'];

// Consulta para traer todos los usuarios excepto el usuario actual
$sql = "SELECT uid, name
        FROM dateperson
        WHERE uid != ?";

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    echo json_encode(["error" => "Error al preparar la consulta"]);
    exit;
}

$stmt->bind_param("i", $uid);

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

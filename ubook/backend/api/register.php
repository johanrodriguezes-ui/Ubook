<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Conexión a la base de datos
include 'db.php';

// Obtener datos del cuerpo de la solicitud POST
$identy = isset($_POST['identy']) ? (int)$_POST['identy'] : 0;
$name = isset($_POST['name']) ? $_POST['name'] : '';
$email = isset($_POST['email']) ? $_POST['email'] : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';
$birthdate = isset($_POST['birthdate']) ? $_POST['birthdate'] : '';
$program = isset($_POST['program']) ? $_POST['program'] : '';


// Validación de campos vacíos
if (empty($identy) || empty($name) || empty($email) || empty($password) || empty($birthdate) || empty($program)) {
    die(json_encode(['success' => false, 'message' => 'Todos los campos son obligatorios']));
}

// Encriptar la contraseña
$password_hash = password_hash($password, PASSWORD_DEFAULT);

// Preparar la consulta para insertar el nuevo usuario en la tabla dateperson
$stmt = $conn->prepare("INSERT INTO dateperson (identy, name, email, password, birthdate, program) VALUES (?, ?, ?, ?, ?, ?)");

// Asignar los valores a la consulta preparada
$stmt->bind_param("isssss", $identy, $name, $email, $password_hash, $birthdate, $program);

// Ejecutar la consulta y verificar si fue exitosa
if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Usuario registrado con exito']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $stmt->error]);
}

// Cerrar la sentencia y la conexión
$stmt->close();
$conn->close();
?>

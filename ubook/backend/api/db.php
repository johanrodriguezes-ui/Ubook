<?php
// Datos de conexión a la base de datos
$servername = "localhost"; // El servidor donde está alojada la base de datos
$username = "root";        // Usuario de la base de datos
$password = "";            // Contraseña del usuario de la base de datos
$dbname = "ubook";      // Nombre de la base de datos

// Crear conexión
$conn = mysqli_connect($servername, $username, $password, $dbname);

// Verificar la conexión
if (!$conn) {
    die("Conexión fallida: " . mysqli_connect_error());
}
?>

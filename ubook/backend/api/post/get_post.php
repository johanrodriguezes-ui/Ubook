
<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Preparar y ejecutar la consulta usando mysqli
    $sql = "SELECT posts.post_id, posts.content, posts.post_date, posts.likes, dateperson.name AS author
            FROM posts
            JOIN dateperson ON posts.user_id = dateperson.uid
            ORDER BY posts.post_date DESC";
    
    $result = mysqli_query($conn, $sql);

    if (!$result) {
        echo json_encode(['error' => mysqli_error($conn)]);
        exit();
    }

    // Recoger los datos de las publicaciones
    $posts = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $posts[] = $row;
    }

    // Devolver los resultados en formato JSON
    echo json_encode($posts);
}
?>
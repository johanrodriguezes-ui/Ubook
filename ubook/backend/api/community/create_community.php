<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

// Verificar si se recibió la solicitud POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Obtener los datos enviados desde Flutter
    $community_name = $_POST['community_name'];
    $community_image = $_POST['community_image']; // Este campo puede ser opcional
    $created_by = $_POST['created_by']; // ID del usuario, que obtendrás desde Flutter

    // Verificar si los campos obligatorios están llenos
    if (!empty($community_name) && !empty($created_by)) {
        // Preparar la consulta para insertar en la tabla `communities`
        $sql = "INSERT INTO communities (community_name, community_image, created_by, created_at) 
                VALUES (?, ?, ?, NOW())";
        
        if ($stmt = $conn->prepare($sql)) {
            // Enlazar los parámetros
            $stmt->bind_param("ssi", $community_name, $community_image, $created_by);

            // Ejecutar la consulta
            if ($stmt->execute()) {
                // Obtener el último ID insertado (ID de la comunidad creada)
                $community_id = $conn->insert_id;

                // Ahora, agregar al creador como miembro de la comunidad en `community_members`
                $sql_add_member = "INSERT INTO community_members (community_id, user_id, joined_at) VALUES (?, ?, NOW())";
                
                if ($stmt_add = $conn->prepare($sql_add_member)) {
                    // El creador se añade como miembro de la comunidad
                    $stmt_add->bind_param("ii", $community_id, $created_by);
                    
                    if ($stmt_add->execute()) {
                        // Respuesta en caso de éxito
                        $response = array(
                            'success' => true,
                            'message' => 'Community created successfully and creator added as member.',
                            'community_id' => $community_id
                        );
                    } else {
                        // Error al añadir al creador como miembro
                        $response = array(
                            'success' => false,
                            'message' => 'Community created, but error adding creator as member: ' . $stmt_add->error
                        );
                    }
                    
                    // Cerrar la segunda consulta
                    $stmt_add->close();
                } else {
                    // Error al preparar la segunda consulta
                    $response = array(
                        'success' => false,
                        'message' => 'Error preparing member insert query: ' . $conn->error
                    );
                }

            } else {
                // Respuesta en caso de error en la ejecución
                $response = array(
                    'success' => false,
                    'message' => 'Error creating community: ' . $stmt->error
                );
            }

            // Cerrar la consulta
            $stmt->close();
        } else {
            // Error al preparar la consulta
            $response = array(
                'success' => false,
                'message' => 'Error preparing query: ' . $conn->error
            );
        }
    } else {
        // Respuesta si los campos obligatorios están vacíos
        $response = array(
            'success' => false,
            'message' => 'Missing required fields.'
        );
    }

    // Cerrar la conexión a la base de datos
    $conn->close();

    // Enviar la respuesta en formato JSON
    echo json_encode($response);
}
?>

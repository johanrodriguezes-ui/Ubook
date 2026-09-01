<?php 
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $community_id = $_POST['community_id'];
    $user_id = $_POST['user_id'];

    // Verificar si los datos fueron recibidos correctamente
    if (!empty($community_id) && !empty($user_id)) {
        // Verificar si el usuario es el creador de la comunidad
        $sql_check_creator = "SELECT created_by FROM communities WHERE community_id = ?";
        if ($stmt_check_creator = $conn->prepare($sql_check_creator)) {
            $stmt_check_creator->bind_param('i', $community_id);
            $stmt_check_creator->execute();
            $stmt_check_creator->bind_result($creator_id);
            $stmt_check_creator->fetch();
            $stmt_check_creator->close();

            // Eliminar al usuario de la comunidad
            $sql_delete_member = "DELETE FROM community_members WHERE community_id = ? AND user_id = ?";
            if ($stmt_delete = $conn->prepare($sql_delete_member)) {
                $stmt_delete->bind_param('ii', $community_id, $user_id);
                if ($stmt_delete->execute()) {
                    // Verificar si el usuario eliminado es el creador
                    if ($user_id == $creator_id) {
                        // Obtener la lista de miembros restantes de la comunidad
                        $sql_get_members = "SELECT user_id FROM community_members WHERE community_id = ?";
                        if ($stmt_get_members = $conn->prepare($sql_get_members)) {
                            $stmt_get_members->bind_param('i', $community_id);
                            $stmt_get_members->execute();
                            $result = $stmt_get_members->get_result();
                            $members = $result->fetch_all(MYSQLI_ASSOC);
                            $stmt_get_members->close();

                            if (count($members) > 0) {
                                // Asignar un nuevo creador a la comunidad (primer miembro de la lista)
                                $new_creator_id = $members[0]['user_id'];
                                $sql_update_creator = "UPDATE communities SET created_by = ? WHERE community_id = ?";
                                if ($stmt_update = $conn->prepare($sql_update_creator)) {
                                    $stmt_update->bind_param('ii', $new_creator_id, $community_id);
                                    $stmt_update->execute();
                                    $stmt_update->close();
                                }
                            } else {
                                // Si no quedan más miembros, eliminar la comunidad
                                $sql_delete_community = "DELETE FROM communities WHERE community_id = ?";
                                if ($stmt_delete_comm = $conn->prepare($sql_delete_community)) {
                                    $stmt_delete_comm->bind_param('i', $community_id);
                                    $stmt_delete_comm->execute();
                                    $stmt_delete_comm->close();
                                }
                            }
                        }
                    }

                    echo json_encode(['status' => 'success']);
                } else {
                    echo json_encode(['status' => 'error', 'message' => 'Error al eliminar el miembro']);
                }
                $stmt_delete->close();
            }
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
    }
}

$conn->close();
?>

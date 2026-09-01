<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include '../db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $groupId = $_POST['group_id'];
    $memberId = $_POST['member_id'];

    // Verificar si los datos fueron enviados correctamente
    if (empty($groupId) || empty($memberId)) {
        echo json_encode(['status' => 'error', 'message' => 'Datos incompletos']);
        exit;
    }

    // Iniciar la transacción
    $conn->begin_transaction();

    try {
        // Eliminar miembro del grupo
        $query = "DELETE FROM groupmembers WHERE group_id = ? AND user_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ii", $groupId, $memberId);
        $stmt->execute();
        $stmt->close();

        // Verificar si el grupo tiene más miembros
        $query = "SELECT user_id FROM groupmembers WHERE group_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $groupId);
        $stmt->execute();
        $result = $stmt->get_result();

        $members = $result->fetch_all(MYSQLI_ASSOC);
        $stmt->close();

        if (count($members) === 0) {
            // Si no hay más miembros, eliminar el grupo y sus mensajes
            $deleteGroupQuery = "DELETE FROM groups WHERE group_id = ?";
            $deleteMessagesQuery = "DELETE FROM groupmessages WHERE group_id = ?";
            
            $stmt = $conn->prepare($deleteMessagesQuery);
            $stmt->bind_param("i", $groupId);
            $stmt->execute();
            $stmt->close();
            
            $stmt = $conn->prepare($deleteGroupQuery);
            $stmt->bind_param("i", $groupId);
            $stmt->execute();
            $stmt->close();

            echo json_encode(['status' => 'success', 'message' => 'Grupo eliminado']);
        } else {
            // Si hay miembros restantes, verificar si el creador es uno de ellos
            if ($memberId == $members[0]['user_id']) { // Si el creador es el que se elimina
                // Asignar un nuevo creador
                $newCreatorId = $members[1]['user_id']; // Tomar el segundo miembro como nuevo creador
                $updateCreatorQuery = "UPDATE groups SET created_by = ? WHERE group_id = ?";
                
                $stmt = $conn->prepare($updateCreatorQuery);
                $stmt->bind_param("ii", $newCreatorId, $groupId);
                $stmt->execute();
                $stmt->close();

                echo json_encode(['status' => 'success', 'message' => 'Miembro eliminado y nuevo creador asignado']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Miembro eliminado']);
            }
        }

        // Confirmar la transacción
        $conn->commit();

    } catch (Exception $e) {
        // Si hay un error, deshacer la transacción
        $conn->rollback();
        echo json_encode(['status' => 'error', 'message' => 'Error al eliminar miembro: ' . $e->getMessage()]);
    } finally {
        $conn->close();
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Método no permitido']);
}
?>

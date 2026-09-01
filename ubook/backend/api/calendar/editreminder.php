<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include '../db.php'; 

$reminder_id = $_POST['reminder_id'];
$reminder_message = $_POST['reminder_message'];
$reminder_date = $_POST['reminder_date'];

$query = "UPDATE calendar SET reminder_message = '$reminder_message', reminder_date = '$reminder_date' WHERE reminder_id = $reminder_id";
if (mysqli_query($conn, $query)) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error']);
}
?>

<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include '../db.php'; 

$user_id = $_GET['user_id'];

$query = "SELECT reminder_id, reminder_message, reminder_date FROM calendar WHERE user_id = $user_id";
$result = mysqli_query($conn, $query);

$reminders = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $reminders[] = $row;
    }
}

echo json_encode($reminders);
?>

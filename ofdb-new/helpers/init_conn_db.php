<?php
$servername = "localhost";
$db_username = "isuri";
$db_password = "isuri@123";
$db_name = 'flighttemp';

$conn = mysqli_connect($servername, $db_username, $db_password,$db_name);

if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}


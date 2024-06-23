<?php
if(isset($_POST['login_but'])) {
    require '../../helpers/init_conn_db.php';
    $email_id = $_POST['user_id'];
    $password = $_POST['user_pass'];
    
    // Call the admin_login stored procedure
    $query = "CALL admin_login(?, ?, @success, @id, @username)";
    $stmt = mysqli_prepare($conn, $query);
    
    if (!$stmt) {
        header('Location: ../../admin/login.php?error=sqlerror');
        exit();            
    } else {
        mysqli_stmt_bind_param($stmt, 'ss', $email_id, $password);            
        mysqli_stmt_execute($stmt);
        
        // Fetch output parameters
        $result = mysqli_query($conn, "SELECT @success, @id, @username");
        $row = mysqli_fetch_assoc($result);
        $success = $row['@success'];
        $id = $row['@id'];
        $username = $row['@username'];
        
        // Check login status
        if ($success) {
            session_start();
            $_SESSION['adminId'] = $id;
            $_SESSION['adminUname'] = $username;
            $_SESSION['adminEmail'] = $email_id;
            header('Location: ../../admin/index.php?login=success');
            exit();
        } else {
            // User authentication failed
            header('Location: ../../admin/login.php?error=invalidcred');
            exit();                    
        }
    }
    mysqli_stmt_close($stmt);
    mysqli_close($conn);
} else {
    header('Location: ../../index.php');
    exit();
}
?>

<?php
if(isset($_POST['login_but'])) {
    require '../helpers/init_conn_db.php'; // Include your database connection script
    
    $email_id = $_POST['user_id'];
    $password = $_POST['user_pass'];
    
    // Call the stored procedure
    $query = "CALL user_login(?, ?, @success, @id, @username)";
    $stmt = mysqli_prepare($conn, $query);
    
    if (!$stmt) {
        header('Location: ../login.php?error=sqlerror');
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
            $_SESSION['userId'] = $id;
            $_SESSION['userUid'] = $username;
            $_SESSION['userMail'] = $email_id;
            setcookie('Uname', $email_id, time() + (86400 * 30), "/");
            setcookie('Upwd', $password, time() + (86400 * 30), "/");                                
            header('Location: ../index.php?login=success');
            exit();
        } else {
            // User authentication failed
            header('Location: ../login.php?error=invalidcred');
            exit();                    
        }
    }
    mysqli_stmt_close($stmt);
    mysqli_close($conn);
} else {
    // Redirect to login page if login button is not set
    header('Location: ../login.php');
    exit();  
}   
?>

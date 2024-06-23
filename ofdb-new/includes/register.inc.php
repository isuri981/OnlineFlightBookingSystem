<?php
if(isset($_POST['signup_submit'])) {
    require '../helpers/init_conn_db.php';    
    $username = $_POST['username'];
    $email_id = $_POST['email_id'];
    $password = $_POST['password'];
    $password_repeat = $_POST['password_repeat'];
    
    // Check if email is valid
    if(!filter_var($email_id, FILTER_VALIDATE_EMAIL)) {
        header('Location: ../register.php?error=invalidemail');
        exit();
    }
    // Check if passwords match
    else if($password !== $password_repeat) {
        header('Location: ../register.php?error=pwdnotmatch');
        exit();
    }
    else {
        // Check if the user already exists with the provided email
        $user_exists_query = "CALL user_register(?, ?, ?, @p_success)";
        $stmt = mysqli_stmt_init($conn);
        
        if(!mysqli_stmt_prepare($stmt, $user_exists_query)) {
            header('Location: ../register.php?error=sqlerror');
            exit();
        }
        
        mysqli_stmt_bind_param($stmt, 'sss', $email_id, $password, $username);
        mysqli_stmt_execute($stmt);
        
        // Fetch output parameter
        $success_query = "SELECT @p_success AS success";
        $result = mysqli_query($conn, $success_query);
        $row = mysqli_fetch_assoc($result);
        $registration_success = $row['success'];

        mysqli_stmt_close($stmt);

        if($registration_success) {
            // Registration successful, proceed with login
            // (Your login logic here)
            header('Location: ../index.php?login=success');
            exit();
        } else {
            // Registration failed due to existing email
            header('Location: ../register.php?error=emailexists');
            exit();
        }
    }
    mysqli_close($conn);
} else {
    header('Location: ../register.php');
    exit();  
}
?>

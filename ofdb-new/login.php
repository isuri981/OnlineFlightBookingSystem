<?php include_once 'helpers/helper.php'; ?>

<?php subview('header.php'); ?>
<link rel="stylesheet" href="assets/css/form.css">
<?php
if(isset($_GET['pwd'])) {
    if($_GET['pwd']=='updated') {
        echo "<script>alert('Your password has been reset!!');</script>";
    }
}    
?>
<?php
if(isset($_GET['error'])) {
    if($_GET['error'] === 'invalidcred') {
        echo '<script>alert("Invalid Credentials")</script>';
    } else if($_GET['error'] === 'wrongpwd') {
        echo '<script>alert("Wrong Password")</script>';
    } else if($_GET['error'] === 'sqlerror') {
        echo"<script>alert('Database error')</script>";
    }
}
if(isset($_COOKIE['Uname']) && isset($_COOKIE['Upwd'])) {
  require 'helpers/init_conn_db.php';   
  $email_id = $_POST['user_id'];
  $password = $_POST['user_pass'];
  $sql = 'SELECT * FROM Users WHERE username=? OR email=?;';
  $stmt = mysqli_stmt_init($conn);
  if(!mysqli_stmt_prepare($stmt,$sql)) {
      header('Location: views/login.php?error=sqlerror');
      exit();            
  } else {
      mysqli_stmt_bind_param($stmt,'ss',$_COOKIE['Uname'],$_COOKIE['Uname']);            
      mysqli_stmt_execute($stmt);
      $result = mysqli_stmt_get_result($stmt);
      if($row = mysqli_fetch_assoc($result)) {
          $pwd_check = password_verify($_COOKIE['Upwd'],$row['password']);
          if($pwd_check == false) {
              setcookie('Uname', '',time() - 3600);
              setcookie('Upwd', '',time() - 3600);              
              header('Location: views/login.php?error=wrongpwd');
              exit();    
          }
          else if($pwd_check == true) {
              session_start();
              $_SESSION['userId'] = $row['user_id'];
              $_SESSION['userUid'] = $row['username'];
              $_SESSION['userMail'] = $row['email'];                            
              header('Location: views/index.php?login=success');
              exit();                  
          } else {
              header('Location: views/login.php?error=invalidcred');
              exit();                    
          }
      }
      header('Location: views/login.php?error=invalidcred');
      exit();         
  }
  header('Location: views/login.php?error=invalidcred');
  exit();      
  mysqli_stmt_close($stmt);
  mysqli_close($conn);
}
?>
<style>
  body {
    background:url('assets/images/bg.jpg') no-repeat 0px 0px;
	background-size: cover;
	font-family: 'Open Sans', sans-serif;
	background-attachment: fixed;
    background-position: center;


  
  }    
  input {
    border :0px !important;
    border-bottom: 2px solid #838383 !important;
    color :#838383 !important;
    border-radius: 0px !important;
    font-weight: bold !important;
    background-color: whitesmoke !important;  
    border: none;
    border-bottom: 2px solid #838383;      
  }
  input:focus {
    border :0px !important;
    border-bottom: 2px solid #424242 !important;
    color :#424242 !important;
    border-radius: 0px !important;
    font-weight: bold !important;   
    margin-bottom: 10px;   
  }

  label {
    color : #838383 !important;
    font-size: 19px;
  }
  h5.form-name {
    color: #838383;
    font-family: 'Courier New', Courier, monospace;
    font-weight: 50;
    margin-bottom: 0px !important;
    margin-top: 10px;
  }
  h5 {
    color: #ffffff;
    font-weight: bold;
    font-size: 22px ;
	  font-family: 'Montserrat', sans-serif;    
  }
  a:hover {
    text-decoration: none;
  }
  /* .btn-outline-light {
    color :#0275d8;
    border-color: #0275d8 !important;
  }
  .btn-outline-light:hover {
    color: white !important;
    background-color: #0275d8 !important;
  } */
  @font-face {
  font-family: 'product sans';
  src: url('assets/css/Product Sans Bold.ttf');
  }
  h1 {
    font-size: 46px !important;
    margin-bottom: 20px;  
    font-family :'product sans' !important;
    font-weight: bolder;
  }
  div.form-out {
    box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);  
    background-color: rgba(127, 200, 255, 0.73) !important;
    padding: 40px;
    margin-top: 60px;
    border-radius: 16px;
  }

  div.form-out input{
    background-color: rgba(127, 200, 255, 0.73) !important;
   
  }
  .input-group {
  position: relative;
  display: inline-block;
  width: 100%;
}
  select {
    float: right;
    font-weight: bold !important;
    color :#838383 !important;
  }
  @media screen and (max-width: 768px){
    body {
      background-color: lightblue;
      background-image: none;
    }
    div.form-out {
    padding: 20px;
    background-color: none !important;
    margin-top: 20px;
  }  
}
</style>
<main>
<div class="container vh-100 mt-0">
  <div class="row mt-5">
    <div class="col-md-3"></div>
      <div class="bg-light form-out col-md-6">
      <h1 class=" text-center" >LOG IN PANEL</h1>
      
      <form method="POST" class=" text-center" 
        action="includes/login.inc.php">

        <div class="form-row">  
            <div class="col-1 p-0 mr-1">
                <i class="fa fa-user" 
                    style="float: right;margin-top:35px;"></i>
            </div> 
          <div class="col-10 mb-2">              
            <div class="input-group">
                <label for="user_id">Email</label>
                <input type="text" name="user_id" id="user_id" required
                   >
              </div>              
          </div>       
          <div class="col-1 p-0 mr-1">
                <i class="fa fa-lock" 
                    style="float: right;margin-top:35px;"></i>
          </div>                
          <div class="col-10">
            <div class="input-group">
                <label for="user_pass">Password</label>
                <input type="password" name="user_pass" id="user_pass"
                      required>
              </div>            
          </div> 

        </div>          
        <div class="row mt-3">
       
          <div class="col">
          <a id="reset-pass" class="mr-5" href="reset-pwd.php"
              style="float: right !important;">Reset Password</a>        
          </div>         
        </div>   
        <div class="row mt-4">
          <div class="col">
            <a href="register.php">
              <button type="button" class="btn btn-sm btn-info mt-3">
                <div style="font-size: 1rem;">
                Register <i class="fas fa-user-plus text-light"></i> 
                </div>
              </button>
            </a> 
          </div> 
          <div class="col">
            <button name="login_but" type="submit" 
              class="btn btn-sm btn-success mt-3">
              <div style="font-size: 1rem;">
              Login <i class="fa fa-lg fa-arrow-right"></i> 
              </div>
            </button>
          </div>       
        </div>       
      
      </form>
    </div>
    <div class="col-md-3"></div>
    </div>
</div>  

<?php subview('footer.php'); ?> 
<script>
$(document).ready(function(){
  $('.input-group input').focus(function(){
    me = $(this) ;
    $("label[for='"+me.attr('id')+"']").addClass("animate-label");
  }) ;
  $('.input-group input').blur(function(){
    me = $(this) ;
    if ( me.val() == ""){
      $("label[for='"+me.attr('id')+"']").removeClass("animate-label");
    }
  }) ;
  // $('#test-form').submit(function(e){
  //   e.preventDefault() ;
  //   alert("Thank you") ;
  // })
});
</script>
</main>

 <?php subview('footer.php'); ?> 
 <footer style="
        position: absolute;
      bottom: 0;
      width: 100%;
      height: 2.5rem;  
    ">
	<em><h5 class="text-light text-center p-0 brand mt-2">
				<img src="assets/images/airtic.png" 
					height="40px" width="40px" alt="">				
          ABC Flight Booking World..!</h5></em>
	<p class="text-light text-center">&copy; <?php echo date('Y')?>- Developed By @isu&#x1F493;</p>
</footer>
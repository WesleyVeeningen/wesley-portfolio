<?php
// Add this file as /var/www/html/plugins-enabled/autologin.php in the adminer image
class Autologin {
  // see: https://github.com/vrana/adminer/blob/7af1ee3702420620641d075ebfd54d4b1d220409/adminer/include/adminer.inc.php#L18-L20
  function credentials() {
    if (!empty($_GET['username'])) return array(SERVER, $_GET["username"], get_password());
    return array($_ENV['MYSQL_HOSTNAME'], 'root', $_ENV['MYSQL_ROOT_PASSWORD']);
  }
  function login($login, $password) {
      return true;
  }
  function loginForm() {
    global $drivers;
    echo '<input type="hidden" name="auth[username]" value="">' . "\n";
    echo '<input type="hidden" name="auth[driver]" value="server">' . "\n";
    echo '<input type="hidden" name="auth[db]" value="' . h($_ENV['MYSQL_DATABASE']) . '">' . "\n";
    echo "<p><input type='submit' value='" . lang('Login with credentials from env file') . "'>\n";
    echo checkbox("auth[permanent]", 1, $_COOKIE["adminer_permanent"], lang('Permanent login')) . "\n";
    return false;
  }
}

return new Autologin();
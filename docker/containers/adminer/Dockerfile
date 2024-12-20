FROM adminer:latest

COPY autologin.php /var/www/html/plugins-enabled/

CMD	[ "php", "-S", "0.0.0.0:8080", "-t", "/var/www/html" ]
[[ ! -f docker/config/mysql.local.env ]] && cp docker/config/mysql.example.env docker/config/mysql.local.env
DB_ROOT_PASSWD=`openssl rand -base64 $(( $RANDOM % 8 + 16 ))|tr -dc _A-Z-a-z-0-9`
sed -i "s/<hier-uw-root-pass>/${DB_ROOT_PASSWD}/" docker/config/mysql.local.env
DB_USER_PASSWD=`openssl rand -base64 $(( $RANDOM % 8 + 16 ))|tr -dc _A-Z-a-z-0-9`
sed -i "s/<hier-uw-user-pass>/${DB_USER_PASSWD}/" docker/config/mysql.local.env

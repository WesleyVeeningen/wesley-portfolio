cp "$(dirname "${BASH_SOURCE[0]}")"/files/mysql.example.env docker/config/mysql.example.env
PJN="${PROJECT_NAME//[^[:alnum:]]/}"
sed -i "s/<hier-uw-databasename>/${PJN:0:61}_db/" docker/config/mysql.example.env
sed -i "s/<hier-uw-username>/${PJN:0:13}_rw/" docker/config/mysql.example.env
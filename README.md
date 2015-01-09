## Usage

```
docker run --name memcached -d -p 11211 sylvainlasnier/memcached
docker run -it --name data -v /data:/data busybox echo "Data container volume /data"
docker run -dit --name db -e MARIADB_PASS="password" tutum/mariadb
docker run -p 80:80 --name web --volumes-from data --link db:db --link memcached:cache -dit -e DB_ENV_MARIADB_PASS=password  -e DOMAIN="www.test-wordpress.com" -e LOCALE="zh-CN" -e TIMEZONE="Asia/Shanghai" -e ADMIN_EMAIL="admin@test-wordpress.com" -e TITLE="wordpress" -e ADMIN_PASSWORD="password" johnnyzheng/centos-nginx-php-wordpress

```

## Customise

## Authors

Author: johnnyzheng (<johnny@itfolks.com.au>)

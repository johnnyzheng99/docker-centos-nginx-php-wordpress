#!/bin/sh
: ${DOMAIN:=$HOSTNAME}; : ${DB_ENV_PASS:="$DB_ENV_MARIADB_PASS"};
DB_NAME=${DOMAIN//./_};SHOP=shop-$DOMAIN;SHOP_PATH=/data/www/$SHOP

export TZ=$TIMEZONE
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

if [[ ! -d /data/conf/nginx/hosts.d/$DOMAIN.conf || "$OVERRIDDEN" == "TRUE" ]]; then
cat > /data/conf/nginx/hosts.d/$DOMAIN.conf <<EOF
server {
      listen      80;
      server_name $DOMAIN;
      root        $SHOP_PATH;
      index       index.php index.html;
      include     /etc/nginx/conf.d/default-*.conf;
      include     /data/conf/nginx/conf.d/default-*.conf;
      include     /etc/nginx/conf.d/php-wordpress.conf;

}
EOF
fi

if [[ ! -d $SHOP_PATH || "$OVERRIDDEN" == "TRUE" ]]; then
    rm -rf $SHOP_PATH
    mv /wordpress $SHOP_PATH
fi

if [[ ! $(wp core is-installed) || "$OVERRIDDEN" == "TRUE" ]]; then
    cd $SHOP_PATH

    echo "--- Generate wordpress config---"
    /usr/local/bin/wp core config --dbname=$DB_NAME \
        --dbuser=$DB_ENV_USER \
        --dbpass=$DB_ENV_PASS \
        --dbhost=db \
        --locale=$LOCALE \
        --allow-root

    echo "--- Reset wordpress database  ---"
    if [ ! $(wp core is-installed) ]; then
        /usr/local/bin/wp db drop --yes --allow-root
    else
        /usr/local/bin/wp db reset --yes --allow-root
    fi

    echo "--- Installing wordpress ---"
    /usr/local/bin/wp core install \
        --url=http://$DOMAIN \
        --title=$TITLE \
        --admin_user=admin \
        --admin_password=$ADMIN_PASSWORD \
        --admin_email=$ADMIN_EMAIL \
        --allow-root
    /usr/local/bin/wp plugin install nginx-helper --activate --allow-root
    /usr/local/bin/wp plugin install w3-total-cache --activate --allow-root
#    /usr/local/bin/wp option update home 'http://$DOMAIN' --allow-root
#    /usr/local/bin/wp option update siteurl 'http://$DOMAIN' --allow-root
#    /usr/local/bin/wp option update admin_email  '$ADMIN_EMAIL' --allow-root
#    /usr/local/bin/wp option update admin_password '$ADMIN_PASSWORD' --allow-root
#    /usr/local/bin/wp user update $ADMIN_EMAIL --display_name=admin --user_pass=$ADMIN_PASSWORD
#    /usr/local/bin/wp option update blogname '$TITLE' --allow-root
#    echo "--- Clean up ---"

    echo "--- Completed ---"
fi
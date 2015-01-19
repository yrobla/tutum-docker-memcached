#!/bin/bash

#create admin account to memcached using SASL
if [ ! -f /.memcached_admin_created ]; then
	/create_memcached_admin_user.sh
fi

echo "host var is $HOST"
sed -i s/ELK_HOST/$HOST/g /etc/logstash-forwarder

service logstash-forwarder restart
/usr/bin/supervisord -n


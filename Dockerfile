FROM ubuntu:trusty
MAINTAINER FENG, HONGLIN <hfeng@tutum.co>

#install memcached
RUN apt-get update && \
    apt-get install -y libevent-dev libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules && \
    apt-get install -y memcached pwgen wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install logstash forwarder
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
RUN apt-get update
RUN apt-get install logstash-forwarder
RUN cd /etc/init.d/
ADD logstash.init /etc/init.d/logstash-forwarder
RUN chmod +x /etc/init.d/logstash-forwarder
RUN update-rc.d logstash-forwarder defaults
ADD supervisord-memcached.conf /etc/supervisor/conf.d/

# add logstash settings
RUN mkdir certs
ADD certs/logstash-forwarder.crt certs/
ADD logstash-forwarder /etc/logstash-forwarder

ADD create_memcached_admin_user.sh /create_memcached_admin_user.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

EXPOSE 11211

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
        mkdir -p /var/log/supervisor
CMD ["/run.sh"]

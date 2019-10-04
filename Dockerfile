#Download base image ubuntu 16.04
FROM ubuntu:16.04

#Update ubuntu
RUN apt-get update

# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt-get install -y nginx php7.0-fpm supervisor wget unzip && \
    rm -rf /var/lib/apt/lists/*

#Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Enable php-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}

# Install Ookla Server
RUN cd /root && \
    mkdir ooklaserver && \
    cd ooklaserver && \
    wget https://install.speedtest.net/ooklaserver/ooklaserver.sh && \
    chmod a+x ooklaserver.sh && \
    echo y | ./ooklaserver.sh install

#Install Ookla Http Legacy

RUN cd /var/www/html && \
    wget http://install.speedtest.net/httplegacy/http_legacy_fallback.zip && \
    unzip http_legacy_fallback.zip && \
    rm http_legacy_fallback.zip 


#Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# Configure Services and Port
COPY start.sh /start.sh
CMD ["./start.sh"]
 
EXPOSE 80 443 8080 

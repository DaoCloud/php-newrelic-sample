FROM php:5.6-apache

RUN apt-get update -q && \
    apt-get install -y wget && \
    echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list && \
    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
    apt-get update -q && \
    apt-get install -y newrelic-php5 && \
    newrelic-install install && \

    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 覆盖 newRelic 配置文件
COPY newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini

COPY src/ /var/www/html/
FROM php:5.6-apache

RUN apt-get update -q && \
    apt-get install -y wget && \

    # Configure the New Relic apt repository 配置 New Relic Apt 库
    echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list && \

    # Trust the New Relic GPG key. 添加 New Relic apt 下载时所需的密钥
    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - && \

    # Update the local package list.
    apt-get update -q && \

    # Install the PHP agent. 安装 New Relic PHP 代理
    apt-get install -y newrelic-php5 && \
    newrelic-install install && \

    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 覆盖 newRelic 配置文件
# COPY newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini 
# OR
RUN sed -i "s/\"REPLACE_WITH_REAL_KEY\"/\${NEW_RELIC_LICENSE_KEY}/g" /usr/local/etc/php/conf.d/newrelic.ini
RUN sed -i "s/\"PHP Application\"/\${NEW_RELIC_APP_NAME}/g" /usr/local/etc/php/conf.d/newrelic.ini

COPY src/ /var/www/html/

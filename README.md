# 如何开发一个 PHP+NewRelic 的生产级 Docker 化应用

目标：我们将为之前创建的 PHP+NewRelic 应用，编写测试代码和创建持续集成环境。本项目代码维护在 Github:DaoCloud/php-newrelic-sample 项目中。

> 本次基础镜像使用位于 [Docker Hub](https://github.com/docker-library/official-images/blob/master/library/php) 的 PHP 官方镜像。

### 创建 PHP 应用容器
首先，选择官方的 PHP 镜像作为项目的基础镜像。

```
FROM daocloud.io/php:5.6-apache
```
> 因所有镜像均位于境外服务器，为了确保所有示例能正常运行，DaoCloud 提供了一套境内[镜像源]()，并与[官方源]()保持同步。

接着，按照 NewRelic 官方 PHP 安装教程，进行脚本的编写。

```

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
```

* `apt-get update` downloads the package lists from the repositories and "updates" them to get information on the newest versions of packages and their dependencies. It will do this for all repositories and PPAs。
* `apt-get install -y newrelic-php5` 安装 NewRelic PHP5 扩展。
* Docker 是分层结构，镜像的大小所有的层次的大小总和。尽量精简我们每次构建镜像的大小。

然后，修改 Newrelic 配置文件。

```
# 覆盖 newRelic 配置文件
COPY newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini
```

* 主要将 `newrelic.appname` 和 `newrelic.license` 按照 Docker 最佳实践通过环境变量的方式暴露出来。

至此，我们 NewRelic 的配置全部完成了,将代码复制到指定目录完成我们镜像构建的最后一步

```
COPY src/ /var/www/html/
```

### 启动 php-newrelic 容器（本地）
最后，我们将构建好的镜像运行起来

```
docker run --name php-newrelic -e NEW_RELIC_LICENSE_KEY=my-newrelic-license NEW_RELIC_APP_NAME=my-app-name -d php-newrelic-image
```

* 使用 `-e` 参数，容器启动时会将环境变量注入到容器中。
* 使用 `--name` 参数，指定容器的名称。
* 使用 `-d` 参数，容器在启动时会进入后台运行。
* `php-newrelic-image` 是由我们上面的 Dockerfile 构建出来的镜像

### 启动 php-newrelic 容器（云端）

比起本地创建，在云端创建会更简单。

「截图」

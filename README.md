# 如何开发一个 PHP + NewRelic 的生产级 Docker 化应用

> 目标：我们将为之前创建的 **[PHP + MySQL](https://github.com/DaoCloud/php-apache-mysql-sample)** 应用，配置由 **[NewRelic](http://www.newrelic.com)** 提供的应用监控探针。

> 本项目代码维护在 **[DaoCloud/php-newrelic-sample](https://github.com/DaoCloud/php-newrelic-sample)** 项目中。

### 创建 PHP 应用容器

> 因所有镜像均位于境外服务器，为了确保所有示例能正常运行，DaoCloud 提供了一套境内镜像源，并与官方源保持同步。

首先，选择官方的 PHP 镜像作为项目的基础镜像。

```Dockerfile
FROM daocloud.io/php:5.6-apache
```

接着，按照 NewRelic 官方 PHP 安装教程，进行脚本的编写。

```Dockerfile
# 安装 NewRelic
RUN mkdir -p /etc/apt/sources.list.d \
    && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' >> /etc/apt/sources.list.d/newrelic.list \

    # 添加 NewRelic APT 下载时用来验证的 GPG 公钥
    && curl -s https://download.newrelic.com/548C16BF.gpg | apt-key add - \

    # 安装 NewRelic PHP 代理
    && apt-get update \
    && apt-get install -y newrelic-php5 \
    && newrelic-install install \

    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

* `apt-get update` 下载从仓库的软件包列表并获取软件包版本信息。
* `apt-get install -y newrelic-php5` 安装 NewRelic PHP5 扩展。
* Docker 镜像所用的 OverlayFS 是多层的，镜像的大小等于所有层次大小的总和，所以我们应该尽量精简每次构建所产生镜像的大小。

然后，修改 NewRelic 配置文件。

```Dockerfile
# 覆盖 NewRelic 配置文件
RUN sed -i 's/"REPLACE_WITH_REAL_KEY"/\${NEW_RELIC_LICENSE_KEY}/g' /usr/local/etc/php/conf.d/newrelic.ini
RUN sed -i 's/"PHP Application"/\${NEW_RELIC_APP_NAME}/g' /usr/local/etc/php/conf.d/newrelic.ini
```

* 主要将 `newrelic.appname` 和 `newrelic.license` 按照 Docker 最佳实践通过环境变量的方式暴露出来。

至此，我们 NewRelic 的配置全部完成了,将代码复制到指定目录完成我们镜像构建的最后一步

```Dockerfile
COPY src/ /var/www/html/
```

### 启动 php-newrelic 容器（本地）

最后，我们将构建好的镜像运行起来

```Shell
root# docker run --name php-newrelic -e NEW_RELIC_LICENSE_KEY=my-newrelic-license -e NEW_RELIC_APP_NAME=my-app-name -d php-newrelic-image
```

* 使用 `-e` 参数，容器启动时会将环境变量注入到容器中。
* 使用 `--name` 参数，指定容器的名称。
* 使用 `-d` 参数，容器在启动时会进入后台运行。
* `php-newrelic-image` 是由我们上面的 `Dockerfile` 构建出来的镜像。

### 启动 php-newrelic 容器（云端）

比起本地创建，在云端创建会更简单。

「截图」

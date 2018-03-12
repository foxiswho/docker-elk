# 拉取docker 所需文件
可以执行命令，也可以直接使用下载 压缩包
```shell
git clone https://github.com/foxiswho/docker-elk.git

cd docker-elk
```

# mysql jar下载
```HTML
https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz
或
https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz
```
下载并解压缩后，进入解压缩后目录把 `mysql-connector-java-5.1.45-bin.jar` 文件复制到`logstash/pipeline/jar`目录下

# 注意.拉取镜像速度非常慢
可以先手工拉取镜像
```SHELL
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:6.2.2
docker pull docker.elastic.co/kibana/kibana-oss:6.2.2
docker pull docker.elastic.co/logstash/logstash-oss:6.2.2
```

在安装组件之前需要确保以下端口没有被占用:5601 (Kibana), 9200 (Elasticsearch), and 5044 (Logstash).

同时需要确保内核参数 vm_max_map_count 至少设置为262144:
```SHELL
sudo sysctl -w vm.max_map_count=262144
```

# 案例：链接其他已经建立好的容器
> 这里值针对自定义网桥
如果你要测试 链接其他容器，那么必须在运行`docker-compose up`之前本案例已经执行完成

## 创建自定义网络 my-lnmp
```SHELL
docker network create my-lnmp
```
## 创建容器 mariadb
### 第一种
接 在创建容器时，直接加入网络`my-lnmp` (`--net=my-lnmp --net-alias mariadb`), 并设置该容器在网络内的别名是`mariadb`
```SHELL
docker run --name mariadb -p 3306:3306 --net=my-lnmp --net-alias mariadb -e MYSQL_ROOT_PASSWORD=root -d mariadb:10.3.5
```
### 第二种
对已经建立好的容器，加入到新的网络`my-lnmp`中
```SHELL
docker network connect my-lnmp mariadb
```


断开网络
```SHELL
docker network disconnect my-lnmp mariadb
```

## 如你使用的本案例 mariadb 容器
那么请在 `docker-compose.yml` 文件中，按如下修改(去掉前面的#号)
```yml
#      my-lnmp:
#          aliases:
#            - logstash
```
修改为：
```YML
      my-lnmp:
          aliases:
            - logstash
```

## 导入测试数据库文件
`example/test.sql`

具体操作略

## 给数据库创建用户和密码，并赋值全部权限
用户名:`test`

密码：`test_password`

具体操作略

## 最后在当前目录下
`README.md` 同级目录 执行
```SHELL
docker-compose up
```
根据拉取镜像的时间不同，创建的时间也不同。
如果 logstash 这个容器启动不成功，可以先执行下一步，然后再执行
```SHELL
docker start docker_elk_1
```

>docker_elk_1 是你建立`logstash`容器的名字

## 镜像创建成功后执行
新 终端中，打开到本根目录执行
```SHELL
chmod -R +x logstash/sbin/*

logstash/sbin/goods_create.sh
```

## 浏览器查看
```SHELL
http://localhost:9200/goods/_doc/_search
```



# A & Q

如果 `mysql` 容器的网络是 默认的 `bridge` (`docker network ls` 可以查看所有网络,`docker inspect xxxxx` 可以查看`xxxxx`容器的配置信息),无法使用 docker-compose 的 `networks` 把指定的容器，直接加入`xxxxx`容器的网络网桥中链接起来，必须 `extra_hosts`ip地址映射加入。
```HTML
http://yukinami.github.io/2017/03/24/Docker-compose%E4%BD%BF%E7%94%A8%E9%BB%98%E8%AE%A4%E7%9A%84bridge%E7%BD%91%E7%BB%9C/
```

如果 `mysql` 容器的网络是 是自定义的网桥，那么可以通过 容器的 `networks` 配置后直接访问


#  其他
原始容器来自  https://github.com/deviantony/docker-elk.git


# Docker ELK stack

[![Join the chat at https://gitter.im/deviantony/docker-elk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/deviantony/docker-elk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Elastic Stack version](https://img.shields.io/badge/ELK-6.2.2-blue.svg?style=flat)](https://github.com/deviantony/docker-elk/issues/248)
[![Build Status](https://api.travis-ci.org/deviantony/docker-elk.svg?branch=master)](https://travis-ci.org/deviantony/docker-elk)

Run the latest version of the ELK (Elasticsearch, Logstash, Kibana) stack with Docker and Docker Compose.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch
and the visualization power of Kibana.

Based on the official Docker images:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker)
* [logstash](https://github.com/elastic/logstash-docker)
* [kibana](https://github.com/elastic/kibana-docker)

**Note**: Other branches in this project are available:

* ELK 6 with X-Pack support: https://github.com/deviantony/docker-elk/tree/x-pack
* ELK 6 in Vagrant: https://github.com/deviantony/docker-elk/tree/vagrant
* ELK 6 with Search Guard: https://github.com/deviantony/docker-elk/tree/searchguard

## Contents

1. [Requirements](#requirements)
   * [Host setup](#host-setup)
   * [SELinux](#selinux)
2. [Getting started](#getting-started)
   * [Bringing up the stack](#bringing-up-the-stack)
   * [Initial setup](#initial-setup)
3. [Configuration](#configuration)
   * [How can I tune the Kibana configuration?](#how-can-i-tune-the-kibana-configuration)
   * [How can I tune the Logstash configuration?](#how-can-i-tune-the-logstash-configuration)
   * [How can I tune the Elasticsearch configuration?](#how-can-i-tune-the-elasticsearch-configuration)
   * [How can I scale out the Elasticsearch cluster?](#how-can-i-scale-up-the-elasticsearch-cluster)
4. [Storage](#storage)
   * [How can I persist Elasticsearch data?](#how-can-i-persist-elasticsearch-data)
5. [Extensibility](#extensibility)
   * [How can I add plugins?](#how-can-i-add-plugins)
   * [How can I enable the provided extensions?](#how-can-i-enable-the-provided-extensions)
6. [JVM tuning](#jvm-tuning)
   * [How can I specify the amount of memory used by a service?](#how-can-i-specify-the-amount-of-memory-used-by-a-service)
   * [How can I enable a remote JMX connection to a service?](#how-can-i-enable-a-remote-jmx-connection-to-a-service)

## Requirements

### Host setup

1. Install [Docker](https://www.docker.com/community-edition#/download) version **1.10.0+**
2. Install [Docker Compose](https://docs.docker.com/compose/install/) version **1.6.0+**
3. Clone this repository

### SELinux

On distributions which have SELinux enabled out-of-the-box you will need to either re-context the files or set SELinux
into Permissive mode in order for docker-elk to start properly. For example on Redhat and CentOS, the following will
apply the proper context:

```console
$ chcon -R system_u:object_r:admin_home_t:s0 docker-elk/
```

## Usage

### Bringing up the stack

**Note**: In case you switched branch or updated a base image - you may need to run `docker-compose build` first

Start the ELK stack using `docker-compose`:

```console
$ docker-compose up
```

You can also choose to run it in background (detached mode):

```console
$ docker-compose up -d
```

Give Kibana a few seconds to initialize, then access the Kibana web UI by hitting
[http://localhost:5601](http://localhost:5601) with a web browser.

By default, the stack exposes the following ports:
* 5000: Logstash TCP input.
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana

**WARNING**: If you're using `boot2docker`, you must access it via the `boot2docker` IP address instead of `localhost`.

**WARNING**: If you're using *Docker Toolbox*, you must access it via the `docker-machine` IP address instead of
`localhost`.

Now that the stack is running, you will want to inject some log entries. The shipped Logstash configuration allows you
to send content via TCP:

```console
$ nc localhost 5000 < /path/to/logfile.log
```

## Initial setup

### Default Kibana index pattern creation

When Kibana launches for the first time, it is not configured with any index pattern.

#### Via the Kibana web UI

**NOTE**: You need to inject data into Logstash before being able to configure a Logstash index pattern via the Kibana web
UI. Then all you have to do is hit the *Create* button.

Refer to [Connect Kibana with
Elasticsearch](https://www.elastic.co/guide/en/kibana/current/connect-to-elasticsearch.html) for detailed instructions
about the index pattern configuration.

#### On the command line

Create an index pattern via the Kibana API:

```console
$ curl -XPOST -D- 'http://localhost:5601/api/saved_objects/index-pattern' \
    -H 'Content-Type: application/json' \
    -H 'kbn-version: 6.2.2' \
    -d '{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}'
```

The created pattern will automatically be marked as the default index pattern as soon as the Kibana UI is opened for the first time.

## Configuration

**NOTE**: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the
configuration of a component.

### How can I tune the Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

It is also possible to map the entire `config` directory instead of a single file.

### How can I tune the Logstash configuration?

The Logstash configuration is stored in `logstash/config/logstash.yml`.

It is also possible to map the entire `config` directory instead of a single file, however you must be aware that
Logstash will be expecting a
[`log4j2.properties`](https://github.com/elastic/logstash-docker/tree/master/build/logstash/config) file for its own
logging.

### How can I tune the Elasticsearch configuration?

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

You can also specify the options you want to override directly via environment variables:

```yml
elasticsearch:

  environment:
    network.host: "_non_loopback_"
    cluster.name: "my-cluster"
```

### How can I scale out the Elasticsearch cluster?

Follow the instructions from the Wiki: [Scaling out
Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## Storage

### How can I persist Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on
your Docker host. Update the `elasticsearch` service declaration to:

```yml
elasticsearch:

  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store Elasticsearch data inside `/path/to/storage`.

**NOTE:** beware of these OS-specific considerations:
* **Linux:** the [unprivileged `elasticsearch` user][esuser] is used within the Elasticsearch image, therefore the
  mounted data directory must be owned by the uid `1000`.
* **macOS:** the default Docker for Mac configuration allows mounting files from `/Users/`, `/Volumes/`, `/private/`,
  and `/tmp` exclusively. Follow the instructions from the [documentation][macmounts] to add more locations.

[esuser]: https://github.com/elastic/elasticsearch-docker/blob/016bcc9db1dd97ecd0ff60c1290e7fa9142f8ddd/templates/Dockerfile.j2#L22
[macmounts]: https://docs.docker.com/docker-for-mac/osxfs/

## Extensibility

### How can I add plugins?

To add plugins to any ELK component you have to:

1. Add a `RUN` statement to the corresponding `Dockerfile` (eg. `RUN logstash-plugin install logstash-filter-json`)
2. Add the associated plugin code configuration to the service configuration (eg. Logstash input/output)
3. Rebuild the images using the `docker-compose build` command

### How can I enable the provided extensions?

A few extensions are available inside the [`extensions`](extensions) directory. These extensions provide features which
are not part of the standard Elastic stack, but can be used to enrich it with extra integrations.

The documentation for these extensions is provided inside each individual subdirectory, on a per-extension basis. Some
of them require manual changes to the default ELK configuration.

## JVM tuning

### How can I specify the amount of memory used by a service?

By default, both Elasticsearch and Logstash start with [1/4 of the total host
memory](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/parallel.html#default_heap_size) allocated to
the JVM Heap Size.

The startup scripts for Elasticsearch and Logstash can append extra JVM options from the value of an environment
variable, allowing the user to adjust the amount of memory that can be used by each component:

| Service       | Environment variable |
|---------------|----------------------|
| Elasticsearch | ES_JAVA_OPTS         |
| Logstash      | LS_JAVA_OPTS         |

To accomodate environments where memory is scarce (Docker for Mac has only 2 GB available by default), the Heap Size
allocation is capped by default to 256MB per service in the `docker-compose.yml` file. If you want to override the
default JVM configuration, edit the matching environment variable(s) in the `docker-compose.yml` file.

For example, to increase the maximum JVM Heap Size for Logstash:

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Xmx1g -Xms1g"
```

### How can I enable a remote JMX connection to a service?

As for the Java Heap memory (see above), you can specify JVM options to enable JMX and map the JMX port on the docker
host.

Update the `{ES,LS}_JAVA_OPTS` environment variable with the following content (I've mapped the JMX service on the port
18080, you can change that). Do not forget to update the `-Djava.rmi.server.hostname` option with the IP address of your
Docker host (replace **DOCKER_HOST_IP**):

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=18080 -Dcom.sun.management.jmxremote.rmi.port=18080 -Djava.rmi.server.hostname=DOCKER_HOST_IP -Dcom.sun.management.jmxremote.local.only=false"
```

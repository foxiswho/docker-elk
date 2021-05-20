# 拉取docker 所需文件
可以执行命令，也可以直接使用下载 压缩包
```shell
git clone https://github.com/foxiswho/docker-elk.git && cd docker-elk && cd dc && chmod +x ./start.sh && ./start.sh
```
自动部署 elasticsearch logstash kibana

# elasticsearch logstash kibana

官方DOCKER地址

https://www.docker.elastic.co/


使用说明，可以`配合`其他容器使用，也可以`独立使用`
# 基本配置
## 注意.端口

在安装组件之前需要确保以下端口没有被占用:5601 (Kibana), 9200 (Elasticsearch), and 5044 (Logstash).

同时需要确保内核参数 vm_max_map_count 至少设置为262144:
```SHELL
sudo sysctl -w vm.max_map_count=262144
```

## 先下载 词库，如果你不需要词库 请PASS

>注意：词库 7.1.1 默认安装了，不需要安装了

https://github.com/medcl/elasticsearch-analysis-ik/releases
```SHELL
wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.1.1/elasticsearch-analysis-ik-7.1.1.zip
```
解压缩 到 `elasticsearch/plugins`目录中，并将文件名改为`analysis-ik`

配置 `analysis-ik/config` 目录下`IKAnalyzer.cfg.xml`文件
```XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
	<comment>IK Analyzer 扩展配置</comment>
	<!--用户可以在这里配置自己的扩展字典 -->
	<entry key="ext_dict">main.dic;extra_main.dic;</entry>
	 <!--用户可以在这里配置自己的扩展停止词字典-->
	<entry key="ext_stopwords"></entry>
	<!--用户可以在这里配置远程扩展字典 -->
	<!-- <entry key="remote_ext_dict">words_location</entry> -->
	<!--用户可以在这里配置远程扩展停止词字典-->
	<!-- <entry key="remote_ext_stopwords">words_location</entry> -->
</properties>
```
最后 修改配置文件 `docker-xxxx.yml` 选择你的配置文件，把如下一行 前面的`#`号删除
```angular2html
#- ./elasticsearch/plugins/analysis-ik:/usr/share/elasticsearch/plugins/analysis-ik
```

## logstash 配置
`logstash/pipeline` 目录下有默认案例，请自行设置。

真正执行的时候，请删除 案例，否则报错

## 容器内相关目录文件位置
### elasticsearch  容器 内目录，文件 位置
```bash
#配置文件
/usr/share/elasticsearch/config/elasticsearch.yml
/usr/share/elasticsearch/config/synonyms.txt

#词库配置文件
/usr/share/elasticsearch/plugins/analysis-ik/config/IKAnalyzer.cfg.xml

#日志目录
/usr/share/elasticsearch/logs

#数据目录
/usr/share/elasticsearch/data
```

### logstash  容器 内目录，文件 位置
```bash
#配置文件
/usr/share/logstash/config/logstash.yml
#日志目录
/usr/share/logstash/logs

#多任务配置目录
/usr/share/logstash/pipeline

```

### kibana  容器 内目录，文件 位置
```bash
#配置文件
/usr/share/kibana/config/kibana.yml
```

## 对外目录映射权限

建立数据存储目录,并目录设置 `777` 权限，否则启动不成功

```YML
chmod -R 777 ./elasticsearch/data
chmod -R 777 ./elasticsearch/logs
chmod -R 777 ./logstash/pipeline
chmod -R 777 ./logstash/logs
```


# 独立使用 elasticsearch logstash kibana 容器
```bash
cd dc
./start.sh
```

# 合作使用，配合其他容器

例如：有个已经建立好的容器，他的网络是 `other`

```bash
docker-compose up -f docker-compose-cooperation.yml
```


# 合作案例, 链接已经建立好的容器
例如：有个已经建立好的容器组 [ https://github.com/foxiswho/docker-compose-nginx-php-mysql ]，
它网络是 `swoole` (查看所有网络命令:`docker network ls`)，

```bash
docker-compose up -f docker-compose-cooperation-swoole.yml
```

说明：主要在配置文件`docker-compose-cooperation-swoole.yml`中 有以下参数
```YML
  swoole:
       external: true
```

# 合作案例, 创建自定义网络 my-lnmp
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
```console
$ docker-compose up -f docker-compose-my-lnmp.yml
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

# 其他 
### mysql jar下载，（已经包含，无需下载）
```HTML
https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz
或
https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz
```
下载并解压缩后，进入解压缩后目录把 `mysql-connector-java-5.1.45-bin.jar` 文件复制到`logstash/pipeline`目录下


# A & Q

如果 `mysql` 容器的网络是 默认的 `bridge` (`docker network ls` 可以查看所有网络,`docker inspect xxxxx` 可以查看`xxxxx`容器的配置信息),无法使用 docker-compose 的 `networks` 把指定的容器，直接加入`xxxxx`容器的网络网桥中链接起来，必须 `extra_hosts`ip地址映射加入。
```HTML
http://yukinami.github.io/2017/03/24/Docker-compose%E4%BD%BF%E7%94%A8%E9%BB%98%E8%AE%A4%E7%9A%84bridge%E7%BD%91%E7%BB%9C/
```

如果 `mysql` 容器的网络是 是自定义的网桥，那么可以通过 容器的 `networks` 配置后直接访问



#  其他
原始容器来自  https://github.com/deviantony/docker-elk.git

# Elastic stack (ELK) on Docker

[![Join the chat at https://gitter.im/deviantony/docker-elk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/deviantony/docker-elk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Elastic Stack version](https://img.shields.io/badge/ELK-6.4.2-blue.svg?style=flat)](https://github.com/deviantony/docker-elk/issues/332)
[![Build Status](https://api.travis-ci.org/deviantony/docker-elk.svg?branch=master)](https://travis-ci.org/deviantony/docker-elk)

Run the latest version of the [Elastic stack](https://www.elastic.co/elk-stack) with Docker and Docker Compose.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch
and the visualization power of Kibana.

Based on the official Docker images from Elastic:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker)
* [logstash](https://github.com/elastic/logstash-docker)
* [kibana](https://github.com/elastic/kibana-docker)

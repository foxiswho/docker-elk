#!/usr/bin/env bash

#当前文件夹路径
DIR=$(cd $(dirname $0); pwd)

mkdir -p ${DIR}/elasticsearch/data
mkdir -p ${DIR}/elasticsearch/logs

mkdir -p ${DIR}/logstash/logs
mkdir -p ${DIR}/logstash/data
mkdir -p ${DIR}/logstash/pipeline


chmod -R 777 ${DIR}/elasticsearch/data
chmod -R 777 ${DIR}/elasticsearch/logs

chmod -R 777 ${DIR}/logstash/pipeline
chmod -R 777 ${DIR}/logstash/logs
chmod -R 777 ${DIR}/logstash/data


docker-compose up -d
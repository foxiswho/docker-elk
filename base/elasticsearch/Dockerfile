ARG ELK_VERSION=7.2.0


# https://github.com/elastic/elasticsearch-docker
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:${ELK_VERSION}
# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu

ENV ELK_VERSION=7.2.0

# https://github.com/medcl/elasticsearch-analysis-ik

# 报错
#RUN elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${ELK_VERSION}/elasticsearch-analysis-ik-${ELK_VERSION}.zip

#RUN elasticsearch-plugin install /data/elasticsearch-analysis-ik-${ELK_VERSION}.zip

RUN yum -y update && yum -y install wget

RUN mkdir -p /data \
&& cd /data \
&& wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${ELK_VERSION}/elasticsearch-analysis-ik-${ELK_VERSION}.zip \
&& cd /usr/share/elasticsearch/plugins/ \
&& mkdir -p /usr/share/elasticsearch/plugins/analysis-ik \
&& chmod -R 777 /usr/share/elasticsearch/plugins/analysis-ik \
&& mkdir -p /usr/share/elasticsearch/plugins/elasticsearch-analysis-ik \
&& cp -rf /data/elasticsearch-analysis-ik-${ELK_VERSION}.zip ./elasticsearch-analysis-ik.zip \
&& unzip elasticsearch-analysis-ik.zip -d elasticsearch-analysis-ik\
&& mv -f ./elasticsearch-analysis-ik/* ./analysis-ik/ \
&& rm -rf elasticsearch-analysis-ik.zip \
&& rm -rf /data/elasticsearch-analysis-ik-${ELK_VERSION}.zip \
&& rm -rf elasticsearch-analysis-ik \
&& ls -a ./ \
&& ls -a ./analysis-ik/ \
&& cat analysis-ik/config/IKAnalyzer.cfg.xml \
&& sed -i 's#<entry key="ext_dict"></entry>#<entry key="ext_dict">main.dic;extra_main.dic;</entry>#g' ./analysis-ik/config/IKAnalyzer.cfg.xml \
&& cat analysis-ik/config/IKAnalyzer.cfg.xml



RUN yum clean all




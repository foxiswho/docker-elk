ARG ELK_VERSION=7.1.1


# https://github.com/elastic/elasticsearch-docker
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:${ELK_VERSION}

# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu

ENV ELK_VERSION=${ELK_VERSION}

# https://github.com/medcl/elasticsearch-analysis-ik
#RUN elasticsearch-plugin install xxx
RUN mkdir -p /data && cd /data && wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${ELK_VERSION}/elasticsearch-analysis-ik-${ELK_VERSION}.zip

ARG ELK_VERSION=7.4.2

# https://github.com/elastic/logstash-docker
FROM docker.elastic.co/logstash/logstash-oss:${ELK_VERSION}

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json


#RUN logstash-plugin install logstash-filter-json

#RUN logstash-plugin install logstash-input-jdbc


ADD jars/mysql-connector-java-8.0.16.jar /usr/share/logstash/logstash-core/lib/jars/mysql-connector-java-8.0.16.jar
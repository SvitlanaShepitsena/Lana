# https://github.com/elastic/kibana-docker
FROM docker.elastic.co/kibana/kibana:5.4.0

USER root
WORKDIR /usr/share/kibana/

RUN bin/kibana-plugin install https://github.com/floragunncom/search-guard-kibana-plugin/releases/download/v5.4.0/searchguard-kibana-5.4.0-2.zip

#RUN chmod +x /usr/share/elasticsearch/plugins/search-guard-5/tools/sgadmin.sh

#RUN ./usr/share/elasticsearch/plugins/search-guard-5/tools/sgadmin.sh



#USER elasticsearch

#EXPOSE 9200


# Add your kibana plugins setup here
# Example: RUN kibana-plugin install <name|url>


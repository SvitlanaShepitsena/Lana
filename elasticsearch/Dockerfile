# https://github.com/elastic/elasticsearch-docker
FROM docker.elastic.co/elasticsearch/elasticsearch:5.5.2
USER root
WORKDIR /usr/share/elasticsearch/

ENV ES_HOSTNAME elasticsearch
ENV ES_PORT 9200

RUN chown elasticsearch:elasticsearch config/elasticsearch.yml
RUN chown -R elasticsearch:elasticsearch data
# install security plugin

RUN bin/elasticsearch-plugin install -b com.floragunn:search-guard-5:5.5.2-16
COPY ./safe-guard/install_demo_configuration.sh plugins/search-guard-5/tools/

COPY ./safe-guard/init-sgadmin.sh plugins/search-guard-5/tools/
RUN chmod +x plugins/search-guard-5/tools/init-sgadmin.sh

COPY ./run.sh /usr/share/elasticsearch/
RUN chmod +x run.sh

COPY ./set_root_pw.sh /usr/share/elasticsearch/
RUN chmod +x set_root_pw.sh

RUN chmod +x plugins/search-guard-5/tools/install_demo_configuration.sh

RUN ./plugins/search-guard-5/tools/install_demo_configuration.sh -y

RUN chmod +x sgadmin_demo.sh

#RUN curl -k -u admin:admin https://localhost:9200/_searchguard/authinfo

RUN yum -y install openssh-server epel-release
RUN yum -y install pwgen
RUN rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config
RUN ssh-keygen -A

#RUN nohup ./set_root_pw.sh &
RUN ./run.sh
RUN usermod -aG wheel elasticsearch


USER elasticsearch

EXPOSE 9200 22

#CMD ./usr/share/elasticsearch/run.sh

#RUN ./plugins/search-guard-5/tools/sgadmin.sh -p 9200 -cd ../sgconfig/ -icl -nhnv  -cacert root-ca.pem -cert kirk.pem -key kirk-key.pem

#ENTRYPOINT ["/usr/share/elasticsearch/run.sh"]
#ENTRYPOINT ["/plugins/search-guard-5/tools/sgadmin.sh", "-cd", "../sgconfig/", "-icl", "-nhnv",  "-cacert", "root-ca.pem", "-cert", "kirk.pem", "-key", "kirk-key.pem"]

#CMD ./plugins/search-guard-5/tools/sgadmin.sh -cd ../sgconfig/ -icl -nhnv  -cacert root-ca.pem -cert kirk.pem -key kirk-key.pem





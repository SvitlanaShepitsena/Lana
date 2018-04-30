FROM ubuntu:trusty

# Prevent dpkg errors
ENV TERM=xterm-256color

# Set mirrors to NZ
RUN sed -i "s/http:\/\/archive./http:\/\/nz.archive./g" /etc/apt/sources.list

# Install Ansible
RUN apt-get update -qy && \
    apt-get install -qy software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update -qy && \
    apt-get install -qy ansible

RUN apt-get install curl -qy

ADD ./ansible/* /ansible/

COPY ./ansible/* /ansible/
# Copy baked in playbooks
COPY ./ansible/activate.yml /ansible/activate.yml

RUN ls -la /ansible/*

# Add volume for Ansible playbooks
VOLUME /ansible
WORKDIR /ansible

# Entrypoint
ENTRYPOINT ["ansible-playbook"]
CMD ["probe.yml"]
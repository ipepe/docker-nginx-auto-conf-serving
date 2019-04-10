FROM ubuntu:18.04
MAINTAINER docker@ipepe.pl

CMD ["/root/docker-entrypoint.sh"]

RUN apt-get update
RUN apt-get install -qq -y ruby cron nginx openssh-server

# create webapp user
RUN groupadd -g 1000 webapp && \
    useradd -m -s /bin/bash -g webapp -u 1000 webapp && \
    echo "webapp:Password1" | chpasswd

RUN rm /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*

COPY src_fs /


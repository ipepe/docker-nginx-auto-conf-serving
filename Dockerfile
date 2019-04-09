FROM ubuntu:18.04
MAINTAINER docker@ipepe.pl


RUN apt-get update
RUN apt-get install -qq -y ruby cron nginx

COPY root_path /

RUN chmod +x /root/docker-entrypoint.sh

CMD ["/root/docker-entrypoint.sh"]
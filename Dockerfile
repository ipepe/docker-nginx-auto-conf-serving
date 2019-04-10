FROM ubuntu:18.04
MAINTAINER docker@ipepe.pl

CMD ["/root/docker-entrypoint.sh"]

RUN apt-get update
RUN apt-get install -qq -y ruby cron nginx

COPY root_path /


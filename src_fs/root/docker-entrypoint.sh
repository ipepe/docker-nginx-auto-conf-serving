#!/usr/bin/env bash

nginx -t

service nginx start
service cron start

ruby /root/runner.rb > /proc/1/fd/1 2>/proc/1/fd/2

tail -f /var/log/nginx/access.log
#!/usr/bin/env bash

nginx -t

service nginx start
service cron start

tail -f /var/log/nginx/access.log
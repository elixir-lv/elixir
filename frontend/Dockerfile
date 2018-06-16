FROM ubuntu:16.04

# create source directory
RUN rm -rf /var/www
RUN mkdir /var/www

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl nginx mc iputils-ping htop

# [Fix  `open() "/run/nginx.pid" failed (2: No such file or directory)`](https://github.com/gliderlabs/docker-alpine/issues/185#issuecomment-246595114)
RUN mkdir -p /run/nginx

WORKDIR /var/www

# Keep alive.
CMD service nginx start && tail -F /var/log/nginx/error.log
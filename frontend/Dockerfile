FROM ubuntu:16.04

# create source directory
RUN rm -rf /var/www
RUN mkdir /var/www

# Install debian packages
RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
RUN apt-get install --yes build-essential inotify-tools cron nano mc htop curl nginx iputils-ping

# Install node
RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs

# [Fix  `open() "/run/nginx.pid" failed (2: No such file or directory)`](https://github.com/gliderlabs/docker-alpine/issues/185#issuecomment-246595114)
RUN mkdir -p /run/nginx
RUN ln -s /var/www/build/nginx/site.conf /etc/nginx/sites-enabled/site.conf

WORKDIR /var/www

# Keep alive.
CMD service nginx start && tail -F /var/log/nginx/error.log

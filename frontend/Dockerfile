FROM ubuntu:16.04

# create source directory
RUN rm -rf /var/www
RUN mkdir /var/www

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl

WORKDIR /var/www

# Keep alive.
CMD tail -f /dev/null
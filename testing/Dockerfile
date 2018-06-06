FROM ubuntu:16.04

# create source directory
RUN rm -rf /var/www
RUN mkdir /var/www

RUN apt-get update && apt-get install -y --no-install-recommends \
	npm \
	curl \
	default-jre \
  libxi6 libgconf-2-4

#install google-chrome
RUN set -xe \
  && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

# Install node.
RUN npm install -g n
RUN n 9.8.0
RUN ln -sf /usr/local/n/versions/node/9.8.0/bin/node /usr/bin/nodejs
RUN npm install -g npm

WORKDIR /var/www
COPY package.json /var/www
RUN npm install
RUN npm install nightwatch -g

# Keep alive.
CMD tail -f /dev/null
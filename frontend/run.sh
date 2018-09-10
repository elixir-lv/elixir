#!/bin/sh

set -e
npm install
npm run build
service nginx start && tail -F /var/log/nginx/error.log
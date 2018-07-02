#!/bin/sh

set -e
service cron start
#cron -f
mix deps.get
mix phx.server
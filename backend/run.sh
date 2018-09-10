#!/bin/sh

set -e
service cron start
mix deps.get
mix ecto.migrate
mix phx.server
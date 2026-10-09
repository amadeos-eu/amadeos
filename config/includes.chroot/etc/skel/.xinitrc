#!/bin/sh
set -eu

xsetroot -cursor_name left_ptr &
exec /usr/local/bin/dazeos-session


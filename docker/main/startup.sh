#!/bin/bash
set -e

/etc/init.d/xrdp start

echo "xrdp sever started"

# change back to user
su - spinaldev

# needed to run parameters CMD
exec "$@"



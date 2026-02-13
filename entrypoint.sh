#!/bin/sh
set -e

# Replace env vars in config
envsubst < /etc/rtpengine/rtpengine.conf > /tmp/rtpengine.conf

# Start rtpengine with generated config
exec /usr/local/bin/rtpengine --config-file=/tmp/rtpengine.conf

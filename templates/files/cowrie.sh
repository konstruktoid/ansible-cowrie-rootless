#!/bin/bash

set -eu

docker pull cowrie/cowrie:latest
docker run --cap-drop=all --cap-add={chown,dac_override,net_bind_service,setgid,setuid} \
  -v$(pwd)/cowrie/var/log:/cowrie/cowrie-git/var/log/cowrie \
  -v$(pwd)/cowrie/etc:/cowrie/cowrie-git/etc:ro \
  -p 2222:2222 cowrie/cowrie:latest

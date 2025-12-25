#!/usr/bin/env bash

set -eou pipefail

docker build --platform="linux/amd64" -t utils utils -f utils/Dockerfile

mkdir -p ${PWD}/data

docker run --rm -v ${PWD}/data:/data --platform="linux/amd64" utils bash -c " \
	qemu-img resize /data/$(basename ${ROOT_DISK}) ${SIZE}
	cat <<EOF > user-data
#cloud-config
ssh_authorized_keys:
- \$(cat /data/id_ed25519.pub)
EOF
cloud-localds user-data.img user-data
"

echo "QCOW2 image expanded to ${SIZE}."

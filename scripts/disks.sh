#!/usr/bin/env bash

set -eou pipefail

docker build --platform="linux/amd64" -t utils utils -f utils/Dockerfile

HOST_DATA_DIR=${PWD}/data
mkdir -p ${HOST_DATA_DIR}

# Create cloud-init user-data file with SSH public key
cat <<EOF > ${HOST_DATA_DIR}/user-data
ssh_authorized_keys:
- \$(cat /data/id_ed25519.pub)
EOF

IMAGE_NAME=$(basename ${IMAGE})
ROOT_DISK_NAME=$(basename ${ROOT_DISK})

docker run --rm -v ${HOST_DATA_DIR}:/data --platform="linux/amd64" -w /data utils bash -c " \
	if [ ! -f ${ROOT_DISK_NAME} ]; then
		cp ${IMAGE_NAME} ${ROOT_DISK_NAME}
		qemu-img resize ${ROOT_DISK_NAME} ${SIZE}
		# convert to ensure 4K alignment for libvirt
		qemu-img convert -f qcow2 -O qcow2 ${ROOT_DISK_NAME} ${ROOT_DISK_NAME}.aligned
		mv ${ROOT_DISK_NAME}.aligned ${ROOT_DISK_NAME}
		cloud-localds -N netplan.yaml user-data.img user-data
		qemu-img resize -f raw user-data.img 1M
	fi
"

echo "QCOW2 image expanded to ${SIZE}."

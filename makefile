SIZE=20G
SSH_KEY=${PWD}/data/id_ed25519
IMAGE=${PWD}/data/image.qcow2
NETPLAN_CONFIG=${PWD}/data/netplan.yaml
ROOT_DISK=${PWD}/data/root.qcow2
CLOUD_INIT_DISK=${PWD}/data/user-data.img
CLOUD_IMG_URL=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

export SIZE SSH_KEY IMAGE NETPLAN_CONFIG ROOT_DISK CLOUD_INIT_DISK CLOUD_IMG_URL

.PHONY: download-qcow expand-qcow vm-define setup start stop help

${IMAGE}:
	mkdir -p ${PWD}/data
	curl -L ${CLOUD_IMG_URL} -o ${IMAGE} --progress-bar

download-qcow: ${IMAGE}

${SSH_KEY}:
	@ssh-keygen -t ed25519 -f ${SSH_KEY} -N "" || true

${NETPLAN_CONFIG}: 
	cp ${PWD}/utils/netplan.yaml ${NETPLAN_CONFIG}

disks: download-qcow ${SSH_KEY} ${NETPLAN_CONFIG}
	scripts/disks.sh

setup: disks
	virsh -c qemu:///session undefine tatame || true
	envsubst < tatame.tpl.xml > tatame.xml
	virsh -c qemu:///session define ${PWD}/tatame.xml

start:
	virsh -c qemu:///session start tatame

stop:
	virsh -c qemu:///session destroy tatame

cleanup:
	virsh -c qemu:///session undefine tatame || true
	rm -f tatame.xml
	rm -f ${ROOT_DISK} ${CLOUD_INIT_DISK}
	rm -f ${SSH_KEY} ${SSH_KEY}.pub

status:
	virsh -c qemu:///session list --all | grep tatame || echo "VM 'tatame' not found."

console:
	virsh -c qemu:///session console tatame
	
ssh:
	ssh -i ${SSH_KEY} ubuntu@localhost -p 2222

help:
	@echo "Available targets:"
	@echo "  download-qcow   - Download the base qcow2 image if not present."
	@echo "  disks           - Define root disk and cloud-init disk."
	@echo "  vm-define       - Define the VM in libvirt using the template."
	@echo "  setup           - Prepare the VM (download, expand, define)."
	@echo "  start           - Start the VM."
	@echo "  stop            - Stop the VM."
	@echo "  help            - Show this help message."

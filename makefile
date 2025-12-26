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

${SSH_KEY}:
	@ssh-keygen -t ed25519 -f ${SSH_KEY} -N "" || true

${NETPLAN_CONFIG}: 
	cp ${PWD}/utils/netplan.yaml ${NETPLAN_CONFIG}

disks: ${IMAGE} ${SSH_KEY} ${NETPLAN_CONFIG}
	scripts/disks.sh

setup: disks
	virsh -c qemu:///session undefine tatame || true
	envsubst < tatame.tpl.xml > tatame.xml
	virsh -c qemu:///session define ${PWD}/tatame.xml

start:
	virsh -c qemu:///session start tatame

console:
	virsh -c qemu:///session console tatame
	
ssh:
	ssh -i ${SSH_KEY} ubuntu@localhost -p 2222

stop:
	virsh -c qemu:///session destroy tatame

cleanup:
	virsh -c qemu:///session undefine tatame || true
	rm -f tatame.xml
	rm -f ${ROOT_DISK} ${CLOUD_INIT_DISK}
	rm -f ${SSH_KEY} ${SSH_KEY}.pub
	ssh-keygen -f ~/.ssh/known_hosts -R "[localhost]:2222"

help:
	@echo "Available targets:"
	@echo "  disks           - Prepare root disk and cloud-init disk."
	@echo "  setup           - Prepare the VM (prepare disks and define domain)."
	@echo "  start           - Start the VM."
	@echo "  console 	     - Connect to the VM console."
	@echo "  ssh             - SSH into the VM."
	@echo "  stop            - Stop the VM."
	@echo "  cleanup         - Undefine the VM and remove created files."
	@echo "  help            - Show this help message."

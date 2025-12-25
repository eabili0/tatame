SIZE=20G
SSH_KEY=${PWD}/data/id_ed25519
ROOT_DISK=${PWD}/data/image.qcow2
CLOUD_INIT_DISK=${PWD}/data/user-data.img
CLOUD_IMG_URL=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

export SIZE SSH_KEY ROOT_DISK CLOUD_INIT_DISK

.PHONY: download-qcow expand-qcow vm-define setup start stop help

${ROOT_DISK}:
	mkdir -p ${PWD}/data
	curl -L ${CLOUD_IMG_URL} -o ${ROOT_DISK} --progress-bar

download-qcow: ${ROOT_DISK}

${SSH_KEY}:
	@ssh-keygen -t ed25519 -f ${SSH_KEY} -N "" || true

disks: download-qcow ${SSH_KEY}
	scripts/disks.sh

vm-define: disks
	virsh -c qemu:///session undefine tatame || true
	@read -sp "Enter password for VM: " VNC_PASSWORD; echo; \
		VNC_PASSWORD=$$VNC_PASSWORD \
		ROOT_DISK=${ROOT_DISK} \
			envsubst < tatame.tpl.xml > tatame.xml
	virsh -c qemu:///session define ${PWD}/tatame.xml

setup: vm-define 
	@echo "VM 'tatame' is defined and ready to start."

start:
	virsh -c qemu:///session start tatame

stop:
	virsh -c qemu:///session destroy tatame

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

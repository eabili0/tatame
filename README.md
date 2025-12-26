# Tatame

A simple toolkit to run Ubuntu VMs on macOS using QEMU and libvirt.

## Overview

Tatame provides a set of scripts and configurations to quickly spin up an Ubuntu 24.04 (Noble) VM on your Mac. It uses QEMU for virtualization, libvirt for VM management, and cloud-init for automated provisioning.

**Features:**
- One-command VM setup
- Automatic SSH key generation and configuration
- Cloud image-based — minimal footprint, fast boot
- Port forwarding for SSH access (localhost:2222)
- Easy cleanup when you're done

## Prerequisites

Before you begin, make sure you have the following installed:

- **Docker** — used to build disk images with proper tools
- **libvirt + QEMU** — for running the VM

### Installing Dependencies

```bash
# Install via Homebrew
brew install qemu libvirt

# Start the libvirt service
brew services start libvirt
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/tatame.git
cd tatame

# Set up and start the VM
make setup
make start

# SSH into your VM
make ssh
```

## Usage

| Command | Description |
|---------|-------------|
| `make setup` | Prepare disks and define the VM |
| `make start` | Start the VM |
| `make ssh` | SSH into the VM (ubuntu@localhost:2222) |
| `make console` | Connect to the VM serial console |
| `make stop` | Stop the VM |
| `make cleanup` | Remove the VM and all generated files |
| `make help` | Show all available commands |

## VM Specifications

| Resource | Default |
|----------|---------|
| Memory | 8 GB |
| vCPUs | 8 |
| Disk | 20 GB (expandable) |
| OS | Ubuntu 24.04 LTS (Noble) |
| SSH Port | 2222 (forwarded to localhost) |
| User | `ubuntu` |

## Project Structure

```
tatame/
├── makefile            # Main automation targets
├── tatame.tpl.xml      # libvirt domain template
├── scripts/
│   └── disks.sh        # Disk preparation script
├── utils/
│   ├── Dockerfile      # Container for disk utilities
│   └── netplan.yaml    # Network configuration
└── data/               # Generated files (gitignored)
    ├── root.qcow2      # VM root disk
    ├── user-data.img   # Cloud-init config disk
    └── id_ed25519      # SSH key pair
```

## Configuration

You can customize the VM by editing variables in the `makefile`:

```makefile
SIZE=20G                    # Root disk size
CLOUD_IMG_URL=https://...   # Ubuntu cloud image URL
```

For advanced customization, modify `tatame.tpl.xml` to adjust memory, CPU, or other VM settings.

## Troubleshooting

### VM won't start
Make sure libvirt is running:
```bash
brew services restart libvirt
```

### SSH connection refused
The VM may still be booting. Wait a few seconds and try again:
```bash
make ssh
```

### Permission issues with qemu:///session
Ensure you're using the session connection (not system). The makefile is configured to use `qemu:///session` by default.

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

## Contributing

This is a personal project and I'm not actively seeking contributions. However, you're welcome to fork this repository and adapt it to your needs.

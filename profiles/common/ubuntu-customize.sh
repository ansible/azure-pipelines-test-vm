set -eux

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=1
export NEEDRESTART_MODE=l

. /etc/os-release

sleep 60  # allow time for cloud-init to update /etc/apt/sources.list

sudo rm -rf /var/log/unattended-upgrades

sudo apt-get clean all -y
sudo apt-get purge needrestart unattended-upgrades -y
sudo apt-get autoremove -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install docker.io -y --no-install-recommends

sudo systemctl start docker

sudo docker pull quay.io/ansible/azure-pipelines-test-container:6.1.0
sudo docker pull quay.io/ansible/azure-pipelines-test-container:7.0.0
sudo docker pull quay.io/ansible/azure-pipelines-test-container:8.0.0

# Enable /var/run/docker.sock for all container jobs.
# See: https://github.com/microsoft/azure-pipelines-agent/pull/5627
cat << ENV_VARS | sudo tee /etc/profile.d/agent_env_vars.sh
export AZP_AGENT_DEFAULT_MAP_DOCKER_SOCKET_TO_FALSE=false
ENV_VARS

cat << UNIT_FILE | sudo tee /etc/systemd/system/cgroup-v1.service
[Unit]
Description=Enable cgroup v1
Before=basic.target
After=sysinit.target
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=mkdir /sys/fs/cgroup/systemd
ExecStart=mount cgroup -t cgroup /sys/fs/cgroup/systemd -o none,name=systemd,xattr

[Install]
WantedBy=basic.target
UNIT_FILE

sudo systemctl enable cgroup-v1

if [ "${VERSION_ID}" = "24.04" ]; then
  # Stay on LTS kernel to avoid issues similar to those seen on GHA with the updated kernel:
  # https://github.com/ansible/ansible/issues/87731
  # https://discourse.ubuntu.com/t/kernel-7-0-is-now-the-default-for-ubuntu-24-04-lts-on-azure/88459
  sudo apt-get install -y linux-azure-lts-24.04
  sudo apt-get remove -y linux-azure
  sudo env DEBIAN_FRONTEND=noninteractive apt-get purge -y 'linux-*-7.0*'
fi

sudo apt-get distclean -y

require_kb_free=10000000
kb_free="$(df --output='avail,target' | grep ' /$' | sed 's/^ *//;' | cut -d ' ' -f 1)"

echo "Free disk space required: ${require_kb_free} KB"
echo "Free disk space remaining: ${kb_free} KB"

if [ "${kb_free}" -lt "${require_kb_free}" ]; then
  echo "Insufficient free disk space remaining"
  exit 1
fi

sleep 1  # allow packer logs to flush

echo Done

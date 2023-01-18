#!/bin/sh
set -e
echo Init success
chmod +x /usr/bin/{crictl,crun,kubeadm,kubelet,nebula,nebula-cert}
chmod +x /opt/cni/bin/*

#Get the MAC address
#MAC=`cat /sys/class/net/eth0/address`
#Should be predefined by export

#Pass it to nebula config for config file mapping
echo "Passing MAC to nebula config"
envsubst < /etc/nebula/config.yaml | sponge /etc/nebula/config.yaml
#I'm not rebuilding the ISO for yaml vs yml again
mv /etc/nebula/config.yaml /etc/nebula/config.yml

#Get the IP address assigned by nebula
echo "Gathering nebula IP"
export NEBULAIP=`nebula-cert print -path /etc/nebula/$MAC/host.crt -json | jq -r '.details.ips[0]' | cut -f1 -d "/"`
echo Using nebula IP of $NEBULAIP

#Tell kubernets about it
echo "Assigning kubeadm config node IP"
envsubst < /etc/kubeadm/kubeadm.conf.yaml | sponge /etc/kubeadm/kubeadm.conf.yaml

#Enable nebula
echo "Enabling nebula"
systemctl enable --now nebula

echo Ready
echo Taking existing disk and zapping it

sgdisk --zap-all /dev/sda
dd if=/dev/zero of=/dev/sda bs=1M count=100 oflag=direct,dsync

echo "Making file system on root device"
mkfs.ext4 /dev/sda
echo "Mounting"
mount /dev/sda /mnt
echo "Enabling crio, configured to use /mnt for container runtimes"
systemctl enable --now crio 
echo "Starting up the join..."
systemctl enable kubelet
kubeadm join --config /etc/kubeadm/kubeadm.conf.yaml
#kubeadm join nearest.ton618.one:6443 --token v1w7o8.w3rjbi1ezfderevp --discovery-token-ca-cert-hash sha256:d4c49500157420962b8a1287b9e23957c0e89b3095c7c50563ed1f21b5a61424
#kubeadm -v5 join nearest.ton618.one:6443 --token wfkspa.l8g8ngzzzrvasjkt --discovery-token-ca-cert-hash sha256:d4c49500157420962b8a1287b9e23957c0e89b3095c7c50563ed1f21b5a61424
echo "Join operation complete."

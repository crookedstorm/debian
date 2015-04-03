#!/bin/bash -eux

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    echo "==> Installing VMware Tools"
    apt-get install -y linux-headers-$(uname -r) build-essential perl

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/vagrant/linux.iso /mnt/cdrom
    #tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
    git clone https://github.com/rasa/vmware-tools-patches.git
    vmware-tools-patches/untar-and-patch.sh /mnt/cdrom/VMwareTools-*.tar.gz
    vmware-tools-distrib/vmware-install.pl -d
    umount /mnt/cdrom
    rmdir /mnt/cdrom
    rm /home/vagrant/linux.iso
    rm -rf /tmp/VMwareTools-* /tmp/vmware-tools-patches /tmp/vmware-tools-distrib
fi

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Installing VirtualBox guest additions"
    apt-get install -y linux-headers-$(uname -r) build-essential perl
    apt-get install -y dkms

    VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
    mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
    rm /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
    rm /home/vagrant/.vbox_version

    if [[ $VBOX_VERSION = "4.3.10" ]]; then
        ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
    fi
fi

if [[ $PACKER_BUILDER_TYPE =~ parallels ]]; then
    echo "==> Installing Parallels tools"

    mount -o loop /home/vagrant/prl-tools-lin.iso /mnt
    /mnt/install --install-unattended-with-deps
    umount /mnt
    rm -rf /home/vagrant/prl-tools-lin.iso
    rm -f /home/vagrant/.prlctl_version
fi

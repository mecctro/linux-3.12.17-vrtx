# 
# Copyright 2014 - 	Matthew Caples
# Modified 			3/19/2014
# 
# Dell Shared PERC8 RAID Controller - Kernel patches
# 
# Running this script will allow access to Dell VRTX Shared
# storage under Linux.
# 
# 
# Original Patch information from the following patch serie:
# 
# 
# Sumit Saxena - MegaRaid driver changes
# 
# http://marc.info/?l=linux-scsi&m=139220849616649&q=raw
# http://marc.info/?l=linux-scsi&m=139220859416673&q=raw
# http://marc.info/?l=linux-scsi&m=139220868116686&q=raw
# http://marc.info/?l=linux-scsi&m=139220874216704&q=raw
# http://marc.info/?l=linux-scsi&m=139374736120535&q=raw
# 
#
# Adam Radford - Updates for scsi-misc
# 
# http://marc.info/?l=linux-scsi&m=139457887925353&q=raw
# http://marc.info/?l=linux-scsi&m=139444509412890&q=raw
# http://marc.info/?l=linux-scsi&m=139444510112891&q=raw
# http://marc.info/?l=linux-scsi&m=139444510812896&q=raw
# http://marc.info/?l=linux-scsi&m=139444512512929&q=raw
# http://marc.info/?l=linux-scsi&m=139444512712930&q=raw
# 

# Install dependencies
apt-get install git-core kernel-package fakeroot build-essential ncurses-dev diffutils patchutils

# Grab the 3.14-rc7 kernel and unpack it
tar -xvJf  linux-3.14-rc7.tar.xz

# Copy all modifications to correct location
cp .config ./linux-3.14-rc7
cp ./patches/megaraid_sas* ./linux-3.14-rc7/drivers/scsi/megaraid
cd ./linux-3.14-rc7/drivers/scsi/megaraid

# Performance patches
patch < megaraid_sas.perf.patch1
patch < megaraid_sas.perf.patch2
# TODO: In 3.14 Stable Kernel patch 3 will bomb & need patched manually
patch < megaraid_sas.perf.patch3
patch < megaraid_sas.perf.patch4
# TODO: In 3.14 Stable Kernel a new patch to line 1827 of megaraid_sas.h should be like so:
# - u8 MR_TargetIdToLdGet(u32 ldTgtId, struct MR_FW_RAID_MAP_ALL *map);
# + u16 MR_TargetIdToLdGet(u32 ldTgtId, struct MR_FW_RAID_MAP_ALL *map);

# VRTX PERC8 RAID Driver patches
patch < megaraid_sas.driver.patch1
patch < megaraid_sas.driver.patch2
patch < megaraid_sas.driver.patch3
patch < megaraid_sas.driver.patch4
patch < megaraid_sas.driver.patch5

# Compile Kernel patched with custom .config
export CONCURRENCY_LEVEL=9 
cd ../../../
make-kpkg clean
make menuconfig
fakeroot make-kpkg --initrd --append-to-version=-vrtx kernel_image kernel_headers

# Install Kernel
dpkg -i linux-headers-*
cd ~

# ProxMox Support will require additional configuration
# TODO: correct all deps before installation
#apt-get install  quilt debhelper autotools-dev libxml2-dev libncurses5-dev linux-libc-dev libnss3-dev libnspr4-dev bzip2 libslang2-dev libldap2-dev perl-modules libcorosync-pve-dev libopenais-pve-dev xsltproc
#git clone https://github.com/proxmox/redhat-cluster-pve.git
#cd redhat-cluster-pve/debian

#nano rules

# change line with: --kernel_src=/
# to include kernel directory: --kernel_src=/root/linux-3.14

nano control

# change line with: pve-headers-2.6.32-19-pve
# to
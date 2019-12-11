#!/bin/bash
# This script gets executed by a UDev rule whenever an external drive is plugged in.
# The following env variables are set by UDev, but can be obtained if the script is executed outside of UDev context:
# - DEVNAME: Device node name (i.e: /dev/sda1)
# - ID_BUS: Bus type (i.e: usb)
# - ID_FS_TYPE: Device filesystem (i.e: vfat)
# - ID_FS_UUID_ENC: Partition's UUID (i.e: 498E-12EF)
# - ID_FS_LABEL_ENC: Partition's label (i.e: YOURDEVICENAME)

# Make sure we have a valid device name
DEVNAME=${DEVNAME:=$1}
if [[ -z $DEVNAME ]]; then
  echo "Invalid device name: $DEVNAME" >> /usr/src/mount.log
  exit 1
fi

# Get required device information
ID_BUS=${ID_BUS:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_BUS/{ print $2 }')}
ID_FS_TYPE=${ID_FS_TYPE:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_TYPE/{ print $2 }')}
ID_FS_UUID_ENC=${ID_FS_UUID_ENC:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_UUID_ENC/{ print $2 }')}
ID_FS_LABEL_ENC=${ID_FS_LABEL_ENC:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_LABEL_ENC/{ print $2 }')}

if [[ -z $ID_BUS || -z $ID_FS_TYPE || -z $ID_FS_UUID_ENC || -z $ID_FS_LABEL_ENC ]]; then
  echo "Could not get device information: $DEVNAME" >> /usr/src/mount.log
  exit 1
fi

# Construct the mount point path
MOUNT_POINT=/mnt/storage-$ID_BUS-$ID_FS_LABEL_ENC-$ID_FS_UUID_ENC

# Bail if file system is not supported by the kernel
if ! grep -qw $ID_FS_TYPE /proc/filesystems; then
  echo "File system not supported: $ID_FS_TYPE" >> /usr/src/mount.log
  exit 1
fi

# Mount device
if findmnt -rno SOURCE,TARGET $DEVNAME >/dev/null; then
    echo "Device $DEVNAME is already mounted!" >> /usr/src/mount.log
else
    echo "Mounting - Source: $DEVNAME - Destination: $MOUNT_POINT" >> /usr/src/mount.log
    mkdir -p $MOUNT_POINT
    mount -t $ID_FS_TYPE -o rw $DEVNAME $MOUNT_POINT
fi

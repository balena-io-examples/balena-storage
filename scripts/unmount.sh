#!/bin/bash
# This script gets executed by a UDev rule whenever an external drive is unplugged.
# The following env variables are set by UDev, but can be obtained if the script is executed outside of UDev context:
# - DEVNAME: Device node name (i.e: /dev/sda1)
# - ID_BUS: Bus type (i.e: usb)
# - ID_FS_TYPE: Device filesystem (i.e: vfat)
# - ID_FS_UUID_ENC: Partition's UUID (i.e: 498E-12EF)
# - ID_FS_LABEL_ENC: Partition's label (i.e: YOURDEVICENAME)

# Make sure we have a valid device name
DEVNAME=${DEVNAME:=$1}
if [[ -z $DEVNAME ]]; then
  echo "Invalid device name: $DEVNAME" >> /usr/src/unmount.log
  exit 1
fi

# Get required device information
ID_BUS=${ID_BUS:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_BUS/{ print $2 }')}
ID_FS_TYPE=${ID_FS_TYPE:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_TYPE/{ print $2 }')}
ID_FS_UUID_ENC=${ID_FS_UUID_ENC:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_UUID_ENC/{ print $2 }')}
ID_FS_LABEL_ENC=${ID_FS_LABEL_ENC:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_LABEL_ENC/{ print $2 }')}

if [[ -z $ID_BUS || -z $ID_FS_TYPE || -z $ID_FS_UUID_ENC || -z $ID_FS_LABEL_ENC ]]; then
  echo "Could not get device information: $DEVNAME" >> /usr/src/unmount.log
  exit 1
fi

# Construct the mount point path
MOUNT_POINT=/mnt/storage-$ID_BUS-$ID_FS_LABEL_ENC-$ID_FS_UUID_ENC

# Unmount device
if findmnt -rno SOURCE,TARGET $DEVNAME >/dev/null; then
  echo "Unmounting device - Source: $DEVNAME - Destination: $MOUNT_POINT" >> /usr/src/unmount.log
  umount -f $MOUNT_POINT
  rmdir $MOUNT_POINT
else
  echo "No mount point found for device $DEVNAME." >> /usr/src/unmount.log
fi

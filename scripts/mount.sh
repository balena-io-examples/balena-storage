#!/bin/bash

DEVNAME=${DEVNAME:=$1}
if [[ -z $DEVNAME ]]; then
	echo "Invalid device name: $DEVNAME" >> /usr/src/mount.log
	exit 1
fi

ID_BUS=${ID_BUS:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_BUS/{ print $2 }')}
ID_FS_TYPE=${ID_FS_TYPE:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_TYPE/{ print $2 }')}
ID_FS_UUID_ENC=${ID_FS_UUID_ENC:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_UUID_ENC/{ print $2 }')}
ID_FS_LABEL_ENC=${ID_FS_LABEL_ENC:=$(udevadm info -n $DEVNAME | awk -F "=" '/ID_FS_LABEL_ENC/{ print $2 }')}

if [[ -z $ID_BUS || -z $ID_FS_TYPE || -z $ID_FS_UUID_ENC || -z $ID_FS_LABEL_ENC ]]; then
	echo "Could not get device information: $DEVNAME" >> /usr/src/mount.log
	exit 1
fi

MOUNT_POINT=/mnt/storage-$ID_BUS-$ID_FS_LABEL_ENC-$ID_FS_UUID_ENC

if [[ $ID_FS_TYPE != 'vfat' && $ID_FS_TYPE != 'ext4' ]]; then
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

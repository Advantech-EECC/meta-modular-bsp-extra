#
# meta-rootfs-enc-core/classes/rootfs_enc.bbclass
#
# In this file we define the class where we add all the context needed for
# the rootfs encryption support. Note that the meta-rootfs-enc needs
# the meta-secure-boot layer being loaded.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

# Image+initramfs up to 128MiB
LINUX_IMAGE_MAX_SIZE = "134217728"

# If FACTORY_KEYS_DIR is not provided, rootfs encryption layer will fail

FACTORY_KEYS_DIR ?= ""
FACTORY_ROOTFS_SHA256_FILE = "factory-rootfs.sha256"
FACTORY_SIG_FILE_SUFFIX = ".sig"
FACTORY_SIGNING_KEY_FILE = "factory-signing.key.pem"
FACTORY_VALIDATION_PUB_FILE = "factory-validation.pub.pem"
INITRAMFS_FACTORY_DIR = "/etc/factory"

# In order to use the dev mapper with 4KB sectors
IMAGE_ROOTFS_ALIGNMENT = "4"
IMAGE_ROOTFS_FSTYPE = "ext4"

# Rationale: using 1024 instead of 4096 (max ssector size), as speed is
# similar and has better disk usage for small files (we make the rootfs
# match the dm-crypt table sector size)
DM_TABLE_SECTOR_SIZE = "1024"

# Because of the 'initramfs' we need to be able to move the FDT address:

# Load address + max image size
KERNEL_DTB_ADDR = "${@hex(int(d.getVar('CONFIG_SYS_LOAD_ADDR') or '0', 0) + int(d.getVar('LINUX_IMAGE_MAX_SIZE') or '0', 0)) if int(d.getVar('CONFIG_SYS_LOAD_ADDR') or '0', 0) > 0 else ''}"

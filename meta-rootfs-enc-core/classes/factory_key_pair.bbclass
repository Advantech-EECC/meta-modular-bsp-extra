#
# meta-rootfs-enc-core/classes/factory_key_pair.bbclass
#
# Track external factory keys on the tasks that consume them
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

# Default, to be replaced with a list of tasks from the involved recipe
FACTORY_KEY_TASKS ?= "do_configure"

python __anonymous() {
    keys_dir = d.getVar("FACTORY_KEYS_DIR")
    if keys_dir:
        key_file = d.getVar("FACTORY_SIGNING_KEY_FILE")
        pub_file = d.getVar("FACTORY_VALIDATION_PUB_FILE")

        if not key_file or not os.path.isfile(os.path.join(keys_dir, key_file)):
            bb.fatal(f"Missing factory private key: {keys_dir}/{key_file}")
        if not pub_file or not os.path.isfile(os.path.join(keys_dir, pub_file)):
            bb.fatal(f"Missing factory public key: {keys_dir}/{pub_file}")

        checksums = f" {keys_dir}/{key_file}:True {keys_dir}/{pub_file}:True"
        for task in d.getVar("FACTORY_KEY_TASKS").split():
            d.appendVarFlag(task, "file-checksums", checksums)
            d.appendVarFlag(task, "vardeps", " FACTORY_KEYS_DIR")
    else:
        bb.fatal("FACTORY_KEYS_DIR not given (required for rootfs-enc)")
}

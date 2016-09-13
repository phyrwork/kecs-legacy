#!/bin/bash

snapshot=$1; shift;

service nfs-kernel-server stop;

echo "Destroying dependencies...";
zfs destroy -rR "lightning/env/kecs";
zfs create "lightning/env/kecs";

echo "Destroying snapshot lightning/db/kecs@$snapshot";
zfs destroy "lightning/db/kecs@$snapshot";
zfs destroy "lightning/db/kecs/data@$snapshot";
zfs destroy "lightning/db/kecs/log@$snapshot";
zfs destroy "lightning/db/kecs/tmp@$snapshot";

echo "Creating new snapshot lightning/db/kecs@$snapshot";
zfs snapshot -r "lightning/db/kecs@$snapshot";

service nfs-kernel-server start;

echo "INFO: You may want to re-clone your shared datasets.";


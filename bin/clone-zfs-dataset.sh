#!/bin/bash

# defaults
base="";

# parse arguments
while [[ $# -gt 0 ]]
do
	key=$1;
	case $key in

		-b|--base)
			shift;
			base=$1; shift ;;

		*)
			break ;;
	esac
done

# setup
subject=$1; shift;
snapshot=$1; shift;

if [ "$base" != "" ]
then
	base="$base/";
fi

service nfs-kernel-server stop ;

# clone
for target in $@
do
	zfs destroy -Rr "$base$target" ;

	zfs create "$base$target" ;

	zfs clone "$subject/data@$snapshot" "$base$target/data" ;
	zfs clone "$subject/log@$snapshot" "$base$target/log" ;
	zfs clone "$subject/tmp@$snapshot" "$base$target/tmp" ;
done

service nfs-kernel-server start ;
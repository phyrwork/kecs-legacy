#!/bin/bash

# defaults
base="";
basecmd="";

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
	basecmd = "-b $base";
fi

# clone
for target in $@
do
	zfs destroy "$base$target" ;

	kecs.clone-zfs-dataset "$basecmd" "$subject" "$snapshot" "$target" ;
done
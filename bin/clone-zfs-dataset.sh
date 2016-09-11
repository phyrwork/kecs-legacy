#!/bin/bash

# defaults
base="";

# parse arguments
while [[ $# -gt 0 ]]
do
	key=$1;
	case $key in

		-o|--base)
			shift;
			base=$1; shift ;;

		*)
			break ;;
	esac
done

# setup
subjects=$1; shift;
subjects=$(zfs list -o name -r $subjects | tail -n +3);

snapshot=$1; shift;

if [ "$base" != "" ]
then
	base="$base/";
fi

# clone
for subject in $subjects
do
	for target in $@
	do
		zfs clone "$subject@$snapshot" "$base$target/$(basename $subject)" ;
	done
done
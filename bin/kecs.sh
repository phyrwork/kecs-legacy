#!/bin/bash

# defaults
host="";
database="";
time_start=0;
time_end=2147483647;
header=false;
author="";

# parse arguments
while [[ $# -gt 0 ]]
do
	key=$1;
	case $key in
		-h|--host)
			shift;
			host=$1; shift ;;

		-d|--database)
			shift;
			database=$1; shift ;;

		-a|--after)
			shift;
			time_start=$1; shift ;;

		-b|--before)
			shift;
			time_end=$1; shift ;;

		-k|--header)
			shift;
			header=true ;;

		*)
			author=$1; break ;;
	esac
done

# validate options
if [ "$host" == "" ]
then
	echo "Error: No host specified. Exiting!";
	exit -1;
fi

if [ "$database" == "" ]
then
	echo "Error: No host specified. Exiting!";
	exit -1;
fi

if [ "$author" == "" ]
then
	echo "Error: No author specified. Exiting!";
	exit -1;
fi

# prepare
opts="-h $host";
if [ $header = false ]
then
	opts+=" -N";
fi
opts+=" $database";

sql="CALL kecs('$author',$time_start,$time_end)";

# execute
mysql $opts <<< $sql;
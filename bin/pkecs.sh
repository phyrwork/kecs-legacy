#!/bin/bash

# defaults
host="";
database="";
time_start=0;
time_end=2147483647;

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
			author_file=$1; break ;;
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

if [ "$author_file" == "" ]
then
	echo "Error: No authors file specified. Exiting!";
	exit -1;
fi

# execute
if [ $header = true ]
then
	echo "username\tscore\tcount\tscore_self\tcount_self";
fi
parallel -N4 --linebuffer --progress --xapply -j16 kecs -h {1} -d {2} -a {3} -b {4} {5} ::: "$host" ::: "$database" ::: "$time_start" ::: "$time_end" :::: "$author_file" ;
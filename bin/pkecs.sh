#!/bin/bash

# defaults
host="127.0.0.1";
database="kecs";
search_after=0;
time_start=0;
time_end=2147483647;
header=false;
num_cpu=4;
mode="array";
authors="";
output_file="";
progress="";

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

		-s|--search-after)
			shift;
			search_start=$1; shift ;;

		-a|--after)
			shift;
			time_start=$1; shift ;;

		-b|--before)
			shift;
			time_end=$1; shift ;;

		-k|--header)
			shift;
			header=true ;;

		-j|--cpu)
			shift;
			num_cpu=$1; shift;;

		-f|--input)
			shift;
			mode="file" ;;

		-o|--output)
			shift;
			output_file=$1; shift ;;

		-p|--progress)
			shift;
			progress="--eta" ;;

		*)
			break ;;
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
	echo "Error: No database specified. Exiting!";
	exit -1;
fi

# prepare
case $mode in
	file)
		authors=$1;
		argsep="::::" ;;
	array)
		authors=$@;
		argsep=":::" ;;
esac

if [ "$authors" == "" ]
then
	case $mode in
		file)
			echo "Error: No authors file specified. Exiting!" ;;
		array)
			echo "Error: No authors specified. Exiting!" ;;
	esac
	exit -1;
fi

# execute
if [ $header = true ]
then
	echo "username	score	count	score_self	count_self";
fi
if [ "$output_file" != "" ]
then
	parallel --linebuffer -j"$num_cpu" kecs -h "$host" -d "$database" -s "$search_after" -a "$time_start" -b "$time_end" "$argsep" $authors | tee "$output_file" ;
else
	parallel --linebuffer -j"$num_cpu" kecs -h "$host" -d "$database" -s "$search_after" -a "$time_start" -b "$time_end" "$argsep" $authors ;
fi
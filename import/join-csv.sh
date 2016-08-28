#!/bin/bash
source ../env.sh;

output=$1;
shift;

echo "Joining CSVs to $output...";

head -n 1 $1 >> $output;

while (( "$#" )); do

	echo "...appending $1";
	tail -n +2 $1 >> $output;
	shift

done

echo "Done!";
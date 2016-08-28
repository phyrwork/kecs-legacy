#!/bin/bash
source ../env.sh;

output=$1;
shift;

echo "Joining CSVs to $output...";

head -n 1 $1 >> $output;

parallel --progress --xapply --line-buffer tail -n +2 $1 ::: $@ >> $output;
	tail -n +2 $1 >> $output;

echo "..done!";
#!/bin/bash
source ../env.sh;

output=$1;
shift;

echo "Joining CSVs to $output...";

head -n 1 $1 > $output;

parallel --progress --xapply --line-buffer tail -n +2 ::: $@ >> $output;

echo "..done!";
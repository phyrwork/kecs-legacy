#!/bin/bash
source ../env.sh;

output = $1;
shift;

head -n 1 $1 >> $output;

while (( "$#" )); do

	tail -n +2 $1 >> $output;
	shift

done
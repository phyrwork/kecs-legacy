#!/bin/bash
source ../env.sh;

grpsize=$1;
shift;

outdir=$1;
shift;

echo "Grouping CSVs into sets of $grpsize...";

head -n 1 $1 > $output;

numout=0;
files=();

for file in $@
do
	files+=($file);
	if [ "${#files[@]}" -ge "$grpsize" ]
	then
		parallel --progress --xapply --line-buffer tail -n +2 ::: $files >> "$outdir/${files[0]}}.grp.csv";
		files=(); # reset file list
	fi
done

echo "..done!";
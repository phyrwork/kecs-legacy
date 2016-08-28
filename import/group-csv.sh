#!/bin/bash
source ../env.sh;

grpsize=$1;
shift;

outdir=$1;
shift;

echo "Grouping CSVs into sets of $grpsize...";



numout=0;
files=();

for file in $@
do
	files+=($file);
	if [ "${#files[@]}" -ge "$grpsize" ]
	then
		outfile="$outdir/${${files[0]}##*/}.grp.csv";
		head -n 1 ${files[0]} > $outfile;
		parallel --progress --xapply --line-buffer tail -n +2 ::: $files >> $outfile;
		files=(); # reset file list
	fi
done

echo "..done!";
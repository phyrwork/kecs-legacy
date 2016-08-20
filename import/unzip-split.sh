for file in $@
do

	echo "Decompressing "${file}"..." ;
	outfile=${file//bz2/json} ;
	cat ${file} | pbzip2 -c -d | split -C 1M -a 2 - ${outfile}. ;

done
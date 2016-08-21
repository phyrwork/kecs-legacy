for file in $@
do

	echo "Decompressing "${file}"..." ;
	outfile=${file//bz2/json} ;

	if [ "$outfile" = "$file" ]
	then
		echo "Output file will overwrite input file. Possible cause: input file not '.bz2'. Aborting!"
		exit 1;
	fi

	case $(uname) in
		"Darwin") cat ${file} | pbzip2 -c -d | split -l 165000 -a 2 - ${outfile}. ;; # split -b splits before the end of the line. Approx. 165K lines per 256M
		"Linux")  cat ${file} | pbzip2 -c -d | split -C 256M   -a 2 - ${outfile}. ;;
		*) ;;
	esac
	
	

done
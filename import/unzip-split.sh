for file in $@
do

	echo "Decompressing "${file}"..." ;
	outfile=${file//bz2/json} ;

	case $(uname) in
		"Darwin") cat ${file} | pbzip2 -c -d | split -l 165000 -a 2 - ${outfile}. ;; # split -b splits before the end of the line. Approx. 165K lines per 256M
		"Linux")  cat ${file} | pbzip2 -c -d | split -C 256M   -a 2 - ${outfile}. ;;
		*) ;;
	esac
	
	

done
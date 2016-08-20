for file in $@
do
	echo "Generating CSV file from "${file}"... " ;

    in=${file} ;
    out=${file//json/csv} ;

    cat ${in} | json2csv -k id,created_utc,author,score -p > ${out} ;

 done

for file in $@
do
	echo "Generating CSV file from "${file}"... " ;

    in=${file} ;
    out=${file//json/csv} ;

    if [ "$out" = "$in" ]
	then
		echo "Output file will overwrite input file. Possible cause: input file not '.json'. Aborting!"
		exit 1;
	fi

    cat ${in} | json2csv -k id,created_utc,link_id,parent_id,author,score -p > ${out} ;

 done

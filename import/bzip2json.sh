for file in $@
do
	output=${file//bz2/json} ;

	echo "Decompressing $file..." ;

	if [ "$output" = "$file" ]
	then
		echo "Output file will overwrite input file. Possible cause: input file not '.bz2'. Aborting!"
		exit -1;
	fi

	cat $file | pbzip2 -c -d > $output;
done
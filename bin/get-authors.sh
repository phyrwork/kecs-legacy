#!/bin/bash

# defaults
host="127.0.0.1";
database="kecs";
after=0;
before=2147483647;
header=false;
output="";

# parse arguments
while [[ $# -gt 0 ]]
do
	key=$1;
	case $key in
		-h|--host)
			shift;
			host=$1; shift ;;

		-d|--database)
			shift;
			database=$1; shift ;;

		-a|--after)
			shift;
			time_start=$1; shift ;;

		-b|--before)
			shift;
			time_end=$1; shift ;;

		-k|--header)
			shift;
			header=true ;;

		-o|--output)
			shift;
			output=$1; shift ;;

		*)
			break ;;
	esac
done

# prepare query
sql="
	SELECT a.username FROM
	(
		SELECT author_id FROM comment WHERE created_utc BETWEEN $after AND $before
		UNION DISTINCT
		SELECT author_id FROM submission WHERE created_utc BETWEEN $after AND $before
	) p
	INNER JOIN author a ON a.author_id = p.author_id;
";

opts="-h $host ";
if [ $header = false ]
then
	opts+="-N ";
fi
opts+="$database ";

# execute
if [ "$output_file" != "" ]
then
	mysql $opts <<< $sql | tee "$output" ;
else
	mysql $opts <<< $sql ;
fi
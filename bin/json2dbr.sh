# defaults
lines=0;
output="";
fields="";

# parse arguments
while [[ $# -gt 0 ]]
do
	key=$1;
	case $key in
		-c|--comments)
			if [ "$fields" != "" ]
			then
				echo "Error: Multiple field sets selected. Exiting!";
				exit -1;
			fi
			shift;
			fields="id,created_utc,link_id,parent_id,author,score" ;;

		-s|--submissions)
			if [ "$fields" != "" ]
			then
				echo "Error: Multiple field sets selected. Exiting!";
				exit -1;
			fi
			shift;
			fields="id,created_utc,author,score" ;;

		-l|--lines)
			shift;
			lines=$1; shift ;;

		-o|--output)
			shift;
			output=$1; shift ;;

		*)
			break ;;
	esac
done

# validate options
if [ "$output" == "" ]
then
	echo "Error: No output path specified. Exiting!";
	exit -1;
fi

if [ "$fields" == "" ]
then
	echo "Error: No field set (i.e comments/submissions) selected. Exiting!";
	exit -1;
fi

# parse json and output csvs
cat "${@:-/dev/stdin}" | kecs.json2csv -l "$lines" -o "$output" -k "$fields";

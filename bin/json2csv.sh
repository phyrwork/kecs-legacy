# defaults
lines=0;
output="";
fields="";

# parse arguments
while [[ $# -gt 0 ]]
do
	key=$1;
	case $key in
		-k|--fields)
			shift;
			fields=$1; shift ;;

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
	echo "Error: No output fields specified. Exiting!";
	exit -1;
fi

# parse json and output csvs
if [ "$lines" -gt "0" ]
then
	cat "${@:-/dev/stdin}" | json2csv -k "$fields" -p | parallel --header : --pipe -N "$lines" "cat > ${output}.{#}.csv";
else
	cat "${@:-/dev/stdin}" | json2csv -k "$fields" -p > "$output.csv";
fi
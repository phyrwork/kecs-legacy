# defaults
host="";
database="";

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

        *)
            files=$@; break ;;
    esac
done

# validate options
if [ "$host" == "" ]
then
    echo "Error: No host specified. Exiting!";
    exit -1;
fi

if [ "$database" == "" ]
then
    echo "Error: No host specified. Exiting!";
    exit -1;
fi

# import data
for file in $@
do

    column_spec=();

    columns=$(cat $file | head -n 1 | tr ',' '\n')

    for column in $columns
    do
        if [ "$column" = "author" ]
        then
        	column_spec+=("username");
        else
        	column_spec+=("@dummy"${#column_spec[@]});
        fi
    done <<< $columns;

    column_spec=$(IFS=,; echo "${column_spec[*]}");

    sql="	LOAD DATA LOCAL INFILE '$file'
    		IGNORE INTO TABLE author
    		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
    		LINES TERMINATED BY '\\n'
    		IGNORE 1 LINES
    		($column_spec);"

    echo "Importing authors from ${file}... ";
    mysql -h "$host" --silent "$database" <<< $sql;

done
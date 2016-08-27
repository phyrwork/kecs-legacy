source ../env.sh;

for file in $@
do

    column_spec=();

    columns=$(cat $file | sed -n 1'p' | tr ',' '\n')

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

    echo "Importing authors from "${file}"... ";
    mysql -h$KECS_HOST --silent $KECS_DATABASE <<< $sql;

done
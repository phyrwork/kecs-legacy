column_spec=();

columns=$(cat $1 | sed -n 1'p' | tr ',' '\n')

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

sql="	LOAD DATA LOCAL INFILE '$1'
		IGNORE INTO TABLE author
		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
		LINES TERMINATED BY '\\n'
		IGNORE 1 LINES
		($column_spec);"

echo $sql;

mysql -hkecs-dev kecs <<< $sql;
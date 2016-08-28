source ../env.sh;

sh import-authors.sh $file;

column_spec=(); 

columns=$(cat $file | sed -n 1'p' | tr ',' '\n')

for column in $columns
do
	case $column in
		"id") column="@link_id" ;;
		*) column=$column ;;
	esac

    column_spec+=($column);

done <<< $columns;

column_spec=$(IFS=,; echo "${column_spec[*]}");

sql="	LOAD DATA LOCAL INFILE '$file'
		IGNORE INTO TABLE submission_raw
		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
		LINES TERMINATED BY '\\n'
		IGNORE 1 LINES
		($column_spec)
		SET
			link_id = CONV(@link_id,36,10);

		UPDATE submission AS s INNER JOIN author AS a ON s.author = a.username
		SET s.author_id = a.author_id;
	";

echo "Importing submissions from "${file}"... ";
mysql -h$KECS_HOST --silent $KECS_DATABASE <<< $sql;
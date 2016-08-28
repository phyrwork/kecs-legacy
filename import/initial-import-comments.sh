source ../env.sh;

sh import-authors.sh $file;

column_spec=(); 

columns=$(cat $file | sed -n 1'p' | tr ',' '\n')

for column in $columns
do
	case $column in
		"id") column="@comment_id" ;;
		"link_id") column="@link_id" ;;
		"parent_id") column="@parent_id" ;;
		*) column=$column ;;
	esac

    column_spec+=($column);

done <<< $columns;

column_spec=$(IFS=,; echo "${column_spec[*]}");

sql="	LOAD DATA LOCAL INFILE '$file'
		IGNORE INTO TABLE comment
		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
		LINES TERMINATED BY '\\n'
		IGNORE 1 LINES
		($column_spec)
		SET
			comment_id = CONV(@comment_id,36,10),
			link_id = CONV(SUBSTRING(@link_id FROM 4),36,10),
			parent_id = CONV(SUBSTRING(@parent_id FROM 4),36,10);

		UPDATE comment AS c INNER JOIN author AS a ON c.author = a.username
		SET c.author_id = a.author_id;
	";

echo "Importing comments from "${file}"... ";
mysql -h$KECS_HOST --silent $KECS_DATABASE <<< $sql;

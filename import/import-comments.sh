column_spec=();

columns=$(cat $1 | sed -n 1'p' | tr ',' '\n')

for column in $columns
do
	case $column in
		"id") column="@id" ;;
		"link_id") column="@link_id" ;;
		"parent_id") column="@parent_id" ;;
		"author") column="@author" ;;
		*) column=$column ;;
	esac

    column_spec+=($column);

done <<< $columns;

column_spec=$(IFS=,; echo "${column_spec[*]}");

sql="	LOAD DATA LOCAL INFILE '$1'
		IGNORE INTO TABLE comment
		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
		LINES TERMINATED BY '\\n'
		IGNORE 1 LINES
		($column_spec)
		SET
			id = CONV(@id,36,10),
			link_id = CONV(SUBSTRING(@link_id FROM 4),36,10),
			parent_id = CONV(SUBSTRING(@parent_id FROM 4),36,10),
			author_id = (SELECT id FROM author WHERE username = @author)
	";

mysql -hkecs-dev kecs <<< $sql;
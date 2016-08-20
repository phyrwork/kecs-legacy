sh import-authors.sh $1;

column_spec=(); 

columns=$(cat $1 | sed -n 1'p' | tr ',' '\n')

for column in $columns
do
	case $column in
		"id") column="@id" ;;
		*) column=$column ;;
	esac

    column_spec+=($column);

done <<< $columns;

column_spec=$(IFS=,; echo "${column_spec[*]}");

sql="	CREATE TEMPORARY TABLE IF NOT EXISTS submission_raw (
			id bigint(11) unsigned NOT NULL,
			created_utc bigint(11) unsigned NOT NULL,
			author char(20) NOT NULL,
			score int(11) NOT NULL,
			PRIMARY KEY (id)
		) ENGINE=TokuDB DEFAULT CHARSET=utf8mb4;
		
		LOAD DATA LOCAL INFILE '$1'
		IGNORE INTO TABLE submission_raw
		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
		LINES TERMINATED BY '\\n'
		IGNORE 1 LINES
		($column_spec)
		SET
			id = CONV(@id,36,10);

		INSERT INTO submission(id,created_utc,author_id,score)
		SELECT s.id,s.created_utc,a.id AS author_id,s.score
		FROM submission_raw AS s INNER JOIN author AS a ON s.author = a.username;
	";

mysql -hkecs-dev kecs <<< $sql;
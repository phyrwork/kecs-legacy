column_spec=();

columns=$(cat $1 | sed -n 1'p' | tr ',' '\n')

for column in $columns
do
	case $column in
		"id") column="@id" ;;
		"link_id") column="@link_id" ;;
		"parent_id") column="@parent_id" ;;
		*) column=$column ;;
	esac

    column_spec+=($column);

done <<< $columns;

column_spec=$(IFS=,; echo "${column_spec[*]}");

sql="	CREATE TEMPORARY TABLE IF NOT EXISTS comment_raw (
			id bigint(11) unsigned NOT NULL,
			created_utc bigint(11) unsigned NOT NULL,
			link_id bigint(11) unsigned NOT NULL,
			parent_id bigint(11) unsigned NOT NULL,
			author char(20) NOT NULL,
			score int(11) NOT NULL,
			PRIMARY KEY (id)
		) ENGINE=TokuDB DEFAULT CHARSET=utf8mb4;
		
		LOAD DATA LOCAL INFILE '$1'
		IGNORE INTO TABLE comment_raw
		FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
		LINES TERMINATED BY '\\n'
		IGNORE 1 LINES
		($column_spec)
		SET
			id = CONV(@id,36,10),
			link_id = CONV(SUBSTRING(@link_id FROM 4),36,10),
			parent_id = CONV(SUBSTRING(@parent_id FROM 4),36,10);

		INSERT INTO comment(id,created_utc,link_id,parent_id,author_id,score)
		SELECT c.id,c.created_utc,c.link_id,c.parent_id,a.id AS author_id,c.score
		FROM comment_raw AS c INNER JOIN author AS a ON c.author = a.username;
	";

mysql -hkecs-dev kecs <<< $sql;
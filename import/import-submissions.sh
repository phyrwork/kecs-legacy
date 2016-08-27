source ../env.sh;

for file in $@
do

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

	sql="	CREATE TEMPORARY TABLE IF NOT EXISTS submission_raw (
				link_id bigint(11) unsigned NOT NULL,
				created_utc bigint(11) unsigned NOT NULL,
				author char(20) NOT NULL,
				score int(11) NOT NULL,
				PRIMARY KEY (comment_id)
			) ENGINE=TokuDB DEFAULT CHARSET=utf8mb4;
			
			LOAD DATA LOCAL INFILE '$file'
			IGNORE INTO TABLE submission_raw
			FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
			LINES TERMINATED BY '\\n'
			IGNORE 1 LINES
			($column_spec)
			SET
				link_id = CONV(@link_id,36,10);

			INSERT INTO submission(link_id,created_utc,author_id,score)
			SELECT s.link_id,s.created_utc,a.author_id AS author_id,s.score
			FROM submission_raw AS s INNER JOIN author AS a ON s.author = a.username;
		";

	echo "Importing submissions from "${file}"... ";
	mysql --h$KECS_HOST --silent $KECS_DATABASE <<< $sql;

done
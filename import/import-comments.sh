source ../env.sh;

for file in $@
do

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

	sql="	CREATE TEMPORARY TABLE IF NOT EXISTS comment_raw (
				comment_id bigint(11) unsigned NOT NULL,
				created_utc bigint(11) unsigned NOT NULL,
				link_id bigint(11) unsigned NOT NULL,
				parent_id bigint(11) unsigned NOT NULL,
				author char(20) NOT NULL,
				score int(11) NOT NULL,
				PRIMARY KEY (link_id)
			) ENGINE=MEMORY CHARSET=utf8mb4;
			
			LOAD DATA LOCAL INFILE '$file'
			IGNORE INTO TABLE comment_raw
			FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
			LINES TERMINATED BY '\\n'
			IGNORE 1 LINES
			($column_spec)
			SET
				comment_id = CONV(@comment_id,36,10),
				link_id = CONV(SUBSTRING(@link_id FROM 4),36,10),
				parent_id = CONV(SUBSTRING(@parent_id FROM 4),36,10);

			INSERT INTO comment(comment_id,created_utc,link_id,parent_id,author_id,score)
			SELECT c.comment_id,c.created_utc,c.link_id,c.parent_id,a.author_id AS author_id,c.score
			FROM comment_raw AS c INNER JOIN author AS a ON c.author = a.username;
		";

	echo "Importing comments from "${file}"... ";
	mysql -h$KECS_HOST --silent $KECS_DATABASE <<< $sql;

done

#!/bin/bash

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
				created_utc int(11) unsigned NOT NULL,
				link_id bigint(11) unsigned NOT NULL,
				parent_id bigint(11) unsigned NOT NULL,
				author char(20) NOT NULL,
				score int(11) NOT NULL,
				PRIMARY KEY (comment_id)
			) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4;
			
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

			ALTER TABLE comment_raw
			ADD INDEX ix_author(author) USING BTREE;

			INSERT IGNORE INTO author(username)
			SELECT c.author
			FROM comment_raw AS c;

			INSERT INTO comment(comment_id,created_utc,link_id,parent_id,author_id,score)
			SELECT c.comment_id,c.created_utc,c.link_id,c.parent_id,a.author_id AS author_id,c.score
			FROM comment_raw AS c INNER JOIN author AS a ON c.author = a.username;
		";

	echo "Importing comments from ${file}... ";
	mysql -h "$host" --silent "$database" <<< $sql;

done

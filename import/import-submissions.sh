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

	sh import-authors.sh $file;

	column_spec=(); 

	columns=$(cat $file | head -n 1 | tr ',' '\n')

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
				created_utc int(11) unsigned NOT NULL,
				author char(20) NOT NULL,
				score int(11) NOT NULL,
				PRIMARY KEY (link_id),
				KEY(author)
			) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4;
			
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

	echo "Importing submissions from ${file}... ";
	mysql -h "$host" --silent "$datbase" <<< $sql;

done
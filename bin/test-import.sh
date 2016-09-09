for file in $@
do
	var=$(sed '2q;d' $file | awk -F"," '{print $1}');
	var=$((36#${var})); # convert from base36
	echo $file;
	mysql kecs <<< "SELECT * FROM comment WHERE comment_id = $var";
done
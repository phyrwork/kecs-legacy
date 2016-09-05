for file in $@
do
	line=$(sed '2q;d' $file | tr ',' '\n');

	for var in $line
    do
        break; # hacky way of getting first element
    done

    var=$((36#var)); # convert from base36

    echo $file;
	echo $(mysql kecs <<< "SELECT * FROM comment WHERE comment_id = $var");
done
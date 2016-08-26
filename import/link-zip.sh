dir="/liberal/db/reddit";

for file in $@
do
	IFS='_-' read -ra parts <<< "$file"

	type=${parts[0]};
	type=${type:(-2)};
	year=${parts[1]};
	leaf=${parts[2]};

	case $type in
		"RC") type="comments" ;;
		"RS") type="submissions" ;;
		*) echo "Unknown file type. Exiting!"; exit 1 ;;
	esac

	test -d "$dir/$type/$year" || mkdir -p "$dir/$type/$year" && ln -s "$file" "$dir/$type/$year/$leaf";
done
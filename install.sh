#!/bin/bash

if [ -z ${1+x} ]
then
	echo "Error: No install directory (e.g. /usr/local/bin) specified. KECS not installed!";
	exit -1;
else
	dir=$1;
fi

ln -sf $(pwd)/bin/link-zip.sh $dir/kecs.link-zip
ln -sf $(pwd)/bin/sort-zip.sh $dir/kecs.sort-zip

ln -sf $(pwd)/bin/bzip2json.sh $dir/kecs.bzip2json
ln -sf $(pwd)/bin/json2csv.sh $dir/kecs.json2csv
ln -sf $(pwd)/bin/json2dbr.sh $dir/kecs.json2dbr

ln -sf $(pwd)/bin/import-authors.sh $dir/kecs.import-authors
ln -sf $(pwd)/bin/import-comments.sh $dir/kecs.import-comments
ln -sf $(pwd)/bin/import-submissions.sh $dir/kecs.import-submissions

ln -sf $(pwd)/bin/import.sh $dir/kecs.import
ln -sf $(pwd)/bin/get-authors.sh $dir/kecs.get-authors

ln -sf $(pwd)/bin/clone-zfs-dataset.sh $dir/kecs.clone-zfs-dataset
ln -sf $(pwd)/bin/update-zfs-dataset.sh $dir/kecs.update-zfs-dataset

ln -sf $(pwd)/bin/unmount-nfs-dataset.sh $dir/kecs.unmount-nfs-dataset
ln -sf $(pwd)/bin/mount-nfs-dataset.sh $dir/kecs.mount-nfs-dataset
ln -sf $(pwd)/bin/remount-nfs-dataset.sh $dir/kecs.remount-nfs-dataset

ln -sf $(pwd)/bin/kecs.sh $dir/kecs
ln -sf $(pwd)/bin/pkecs.sh $dir/pkecs
host=$1;
database=$2;
author_file=$3;
time_start=$4;
time_end=$5;

parallel --linebuffer --progress --xapply -j16 ./kecs.sh ::: $1 ::: $2 :::: $3 ::: $4 ::: $5
host=$1;
database=$2;
author=$3;
time_start=$4;
time_end=$5;

sql="CALL kecs('$author',$time_start,$time_end)";

mysql -h$host $database <<< $sql | tail -n +2;
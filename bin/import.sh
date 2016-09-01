#!/bin/bash

# defaults
host="";
database="";
snapdata="";
snapfreq=0;
mode="";
logfile="";

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

		-z|--snapdata)
			shift;
			snapdata=$1; shift ;;

		-f|--snapfreq)
			shift;
			snapfreq=$1; shift ;;

		-l|--logfile)
			shift;
			logfile=$1; shift ;;

		-a|--author)
			shift;
			mode="author" ;;

		-s|--submission)
			shift;
			mode="submission" ;;

		-c|--comment)
			shift;
			mode="comment" ;;

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

if [ "$snapfreq" -gt "0" ]
then
	if [ "$snapdata" == "" ]
	then
		echo "Error: Snapshots enabled but no recordset specifed. Exiting!";
		exit -1;
	fi
fi

if [ "$mode" == "" ]
then
	echo "Error: Data type (i.e. author/submission/comment) not specified. Exiting!";
	exit -1;
fi

# import data
snapnum=0;
for file in $@
do
	if [ "$logfile" != "" ]
	then
		echo "Importing $file..." >> $logfile;
	fi

	# import file
	case $mode in
		author)
			kecs.import-authors -h "$host" -d "$database" "$file";
			;;
		submissions)
			kecs.import-submissions -h "$host" -d "$database" "$file";
			;;
		comment)
			kecs.import-comments -h "$host" -d "$database" "$file";
			;;
		*)
			echo "Error: Unknown data type specified. Exiting!";
			exit -1;
	esac

	# snapshots
	snapnum+=1;
	if [ "$snapfreq" -gt "0" ]
	then
		if [ "$snapnum" -ge "$snapfreq" ]
		then
			snapname = $(echo $(basename $file) | sed -e 's/[^A-Za-z0-9._-]/_/g');

			if [ "$logfile" != "" ]
			then
				echo "Taking snapshot $snapname..." >> $logfile;
			fi
			
			service mysql stop;
			zfs snapshot "${snapdata}@${snapname}";
			service mysql start;

			snapnum=0;
		fi
	fi
done

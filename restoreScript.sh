#!/bin/sh


DATADIR="/var/lib/cassandra/data/"
rm -f /var/lib/cassandra/commitlog/*

SCHEMAS=$(ls "$DATADIR" | grep -vw "system" | grep -vw "system_traces")
for s in $SCHEMAS
do
	TABLES=$(ls "$DATADIR/$s")
	for t in $TABLES
	do
		#Check if snapshots directory exists
		if [ ! -d "$DATADIR"/"$s"/"$t"/snapshots ]; then
			echo "NO snapshots directory exists"
			exit 2
		fi
		SNAPSHOTS=$(ls "$DATADIR"/"$s"/"$t"/snapshots | sort -nr)
		rm -f "$DATADIR"/"$s"/"$t"/*.db "$DATADIR"/"$s"/"$t"/*.txt

		#if incremental backups are enabled, then get the files from the backups directory
		if [ -d "$DATADIR"/"$s"/"$t"/backups ]; then
			#echo "backups are here in $t"
			cp "$DATADIR"/"$s"/"$t"/backups/* "$DATADIR"/"$s"/"$t"
		fi
		#gets the most recent shapshot		
		for r in $SNAPSHOTS
		do
			echo $r
			cp "$DATADIR"/"$s"/"$t"/snapshots/"$r"/* "$DATADIR"/"$s"/"$t"
			break
		done
	done
done
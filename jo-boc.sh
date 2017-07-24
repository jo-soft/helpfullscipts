#!/bin/bash

set -ex
if [ -z $2 ]; then
	source ./jo-boc.conf	
else
	source $2
fi

INOTIFY=`which inotifywait`

# always watch the current directoy for write changes
INOTIFY_PARAMS=" -mq -e close_write --format %f ."

mkdir -p $DST
while true; do
	$INOTIFY $INOTIFY_PARAMS| while read  FILE; do
		
		[[ $FILE != $SRC ]] &&  break
		# Copy new files
		DATE=`date +$DATE_FORMAT`
		FILE_DST=$DST/$DATE$FILE
  		echo copy $FILE to $FILE_DST
		cp $FILE $FILE_DST
	done
done

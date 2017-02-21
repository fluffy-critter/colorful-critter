#!/bin/sh
#
# Update the art assets

# poses

cd $(dirname $0)
BASE=$PWD
DEST=$BASE/src/assets/poses

cd $BASE/raw_assets/flat_poses
find . -name '*.png' -type f | while read fname ; do
    dir=$(dirname $fname)
    mkdir -p $DEST/$dir
    if [ "$fname" -nt "$DEST/$fname" ] ; then
        printf "%s -> %s\n" $fname $DEST/$fname
        convert -resize 512x512 $fname $DEST/$fname
    fi
done

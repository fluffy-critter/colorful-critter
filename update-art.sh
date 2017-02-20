#!/bin/sh
#
# Update the art assets

# poses

cd $(dirname $0)
BASE=$PWD
DEST=$BASE/src/assets/poses

cd $BASE/raw_assets/flat_poses
find . -name '*.png' -type f | while read fname ; do
    printf "%s -> %s\n" $fname $DEST/$fname
    dir=$(dirname $fname)
    mkdir -p $DEST/$dir
    convert -resize 256x256 $fname $DEST/$fname
done

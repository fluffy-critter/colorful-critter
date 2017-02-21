#!/bin/sh
#
# Update the art assets

# poses

cd $(dirname $0)
BASE=$PWD

cd $BASE/raw_assets/flat_poses
find . -name '*.png' -type f | while read fname ; do
    srcdir=$(dirname $fname)
    outdir=$BASE/src/assets/poses/$srcdir
    outfile=$outdir/$(basename $fname)

    mkdir -p $outdir
    if [ "$fname" -nt "$outfile" ] ; then
        printf "%s -> %s\n" $fname $outfile
        convert -resize 512x512 $fname $outfile
    fi
done

cd $BASE/raw_assets/sound
find . -name '*.wav' -type f | while read fname ; do
    srcdir=$(dirname $fname)
    outdir=$BASE/src/sound/$srcdir
    outfile=$outdir/$(basename $fname .wav).ogg

    mkdir -p $outdir
    if [ "$fname" -nt "$outfile" ] ; then
        printf "%s -> %s\n" $fname $outfile
        oggenc "$fname" -o "$outfile"
    fi
done

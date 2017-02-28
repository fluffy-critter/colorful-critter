#!/bin/sh
#
# Update the art assets

# poses

cd $(dirname $0)
BASE=$PWD

cd $BASE/raw_assets/flat_poses

# do everything except the uvmaps
find . -name '*.png' -type f | grep -v 'uv' | while read fname ; do
    srcdir=$(dirname $fname)
    outdir=$BASE/src/assets/poses/$srcdir
    outfile=$outdir/$(basename $fname)

    mkdir -p $outdir
    if [ "$fname" -nt "$outfile" ] ; then
        printf "%s -> %s\n" $fname $outfile
        convert $fname -resize 512x512 $outfile
    fi
done

build_uvmap() {
    outfile=$BASE/src/assets/poses/$1
    shift
    infiles="$@"

    dirty=
    for f in $infiles ; do
        if [ "$f" -nt "$outfile" ] ; then
            dirty=1
        fi
    done

    if [ $dirty ] ; then
        rm -f $outfile
        echo "$outfile"

        cmd=""
        for f in $infiles ; do
            cmd="$cmd ( $f -resize 512x512 -channel alpha -threshold 50% )"
        done

        convert -background transparent $cmd -flatten $outfile
    fi
}

# common uvmaps
for i in */uv1.png ; do
    srcdir=$(dirname $i)
    files=$(ls $srcdir/uv*.png | sort -nr)
    build_uvmap $srcdir/uvmap.png $files
done

# special-case uvmaps
build_uvmap aroused/hyperorgasm-uvmap.png $(ls aroused/uv[2-4].png | sort -nr) aroused/hyperorgasm-uv1.png
build_uvmap aroused/orgasm-uvmap.png $(ls aroused/uv[2-4].png | sort -nr) aroused/orgasm-uv1.png

cd $BASE/raw_assets/icons
find . -name '*.png' -type f | while read fname ; do
    srcdir=$(dirname $fname)
    outdir=$BASE/src/assets/$srcdir
    outfile=$outdir/$(basename $fname)

    mkdir -p $outdir
    if [ "$fname" -nt "$outfile" ] ; then
        printf "%s -> %s\n" $fname $outfile
        convert $fname -resize 32x32 -quantize transparent +dither -colors 256 $outfile
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

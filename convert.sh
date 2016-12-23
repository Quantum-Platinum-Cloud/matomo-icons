#!/bin/bash
shopt -s globstar
size=16

for i in src/**/*.{png,gif,jpg,ico}; do
    echo "$i"
    absDirname=$(dirname "$i")
    origFilename=$(basename "$i")
    code=${origFilename%.*}
    dirname="dist/${absDirname#src/}"
    distFile="${dirname}/${code}.png"
    echo "$distFile"
    if [ ! -d "$dirname" ]
    then
        mkdir -p "$dirname"
    fi
    if [[ $i == *.ico ]]
    then
        if file "$i" | grep -E "HTML|empty|  data" # if no valid image
        then
            rm "$i"
        else
            if [ ! -d "tmp" ]
            then
                mkdir "tmp"
            fi
            largestIcon=$(python analyseIco.py "$i")
            newIcon="tmp/${code}.ico"
            convert ${i}\[$largestIcon\] $newIcon
            i=$newIcon
        fi
    fi
    convert \
        "$i" \
        -strip \
        -transparent white \
        -background none \
        -trim \
        -resize ${size}x${size} \
        -gravity center \
        -extent ${size}x${size} \
        "$distFile"
        # input file
        # strip metadata
        # make background transparent
        # keep transparency
        # cut border
        # get only one image from .ico
        # resize while keeping the aspect ratio
        # center image
        # fit to 16x16
    # optimize png:
    optipng -o 9 -q "$distFile"
    echo ""
done

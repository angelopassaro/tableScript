#!/bin/bash
function initialize() {
    inpath=$(readlink -f $1)
    outpath=$(readlink -f $2)
    
    files=()
    # take all directories from input directory
    for dir in $inpath/*/
    do
        dir=${dir%*/}
        extension=${dir##/*/}
        
        files+=("$outpath.$extension")
        
        compute $dir $extension &
        
    done
    wait
    
    # merge all files
    for file in "${files[@]}"
    do
        cat $file >> $outpath
        rm $file
    done
    
    # clear duplicate
    sort -u -k 1,1 $outpath -o $outpath
    #sort records by type
    sort -k 2 $outpath -o $outpath
    
    echo "Start new directory?(y\n)"
    read decision
    
    if [[ "$decision" = 'y' ]]
    then
        echo "Insert directory"
        read directory
        
        initialize $directory $2
    else
        echo "closed"
        return 1
    fi
}


# compute md5 for all files in a directory
function compute() {
    
    for x in $1/*
    do
        echo "$(md5sum $x) ${x##/*.} $(du -h $x)" | gawk '{print $1 "\t\t\t" $3 "\t" $4 }' >> $outpath"."$2
    done
}


if (( $# != 2 ))
then
    echo "No arguments supplied"
    echo "Usage: start inputdirectory outputfile"
    return 1
else
    initialize $1 $2
fi



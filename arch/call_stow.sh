#!/bin/bash

# echo all arguments in for loop    
for dir in "$@"
do
    # call symlinks.sh in each directory
    cd $dir
    echo "Calling symlinks.sh in $dir"
    sh symlinks.sh

done



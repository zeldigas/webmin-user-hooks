#!/bin/bash

function relpath(){    

    if [[ "$1" == "$2" ]]
    then
	echo "."
	exit
    fi

    IFS="/"

    current=($1)
    absolute=($2)

    abssize=${#absolute[@]}
    cursize=${#current[@]}


    while [[ ${absolute[level]} == ${current[level]} ]];
    do       
	(( level++ ))
	if (( level > abssize || level > cursize ))
	then
            break
	fi
    done

    for ((i = level; i < cursize; i++));
    do
	if ((i > level))
	then
            newpath=$newpath"/"
	fi
	newpath=$newpath".."
    done

    for ((i = level; i < abssize; i++));
    do
	if [[ -n $newpath ]]
	then
            newpath=$newpath"/"
	fi
	newpath=$newpath${absolute[i]}
    done

    echo "$newpath"

}

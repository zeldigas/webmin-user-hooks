#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname  "$0" )" && pwd )"

SH_DIR="$SCRIPT_DIR/run.d"

if [[ -d $SH_DIR ]]; 
then
	cd $SH_DIR
	for shell_file in $SH_DIR/[0-9]*.sh ;
	do
		. $shell_file
	done
fi

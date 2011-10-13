#!/bin/bash


GROUP_PATTERN="^class[0-9]+[:alpa:]*"

CLASS_GROUPS_DIR=/srv/user_dirs/groups_dir
DIR_GROUP=class_admins

group_name=$USERADMIN_GROUP

function matches_pattern(){
    echo $@ | grep -qE $GROUP_PATTERN -
}

function create_group_dir(){
    if matches_pattern $group_name ;
    then
	new_dir_path="$CLASS_GROUPS_DIR/$group_name"
	mkdir "$new_dir_path"
	chgrp $DIR_GROUP "$new_dir_path"
	chmod 775 "$new_dir_path"
    fi
}

function delete_group_dir(){
    rm -f "$CLASS_GROUPS_DIR/$1/"*
    rmdir "$CLASS_GROUPS_DIR/$1"
}

function remove_group_dir(){
    delete_group_dir "$group_name"
}

function modify_group_dir(){
    if matches_pattern $USERADMIN_OLD_GROUP && [[ "$USERADMIN_OLD_GROUP" != "$group_name" ]];
    then
	if matches_pattern $group_name ;
	then
	    mv "$CLASS_GROUPS_DIR/$USERADMIN_OLD_GROUP" "$CLASS_GROUPS_DIR/$group_name"
	else
	    delete_group_dir "$USERADMIN_OLD_GROUP"
	fi
    fi
}

case "$USERADMIN_ACTION" in
    "CREATE_GROUP")
	crete_group_dir
	;;
    "DELETE_GROUP")
	remove_group_dir
	;;
    "MODIFY_GROUP")
	modify_group_dir
	;;
    *)
	
esac

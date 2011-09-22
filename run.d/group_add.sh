#!/bin/bash


GROUP_PATTERN="^class[1-9]+[:alpa:]*"

CLASS_GROUPS_DIR=/srv/user_dirs/groups_dir

group_name=$USERADMIN_GROUP

function create_group_dir(){
    if echo $group_name | grep -qE $GROUP_PATTERN - ;
    then
	mkdir "$CLASS_GROUPS_DIR/$group_name"
    fi
}

function remove_group_dir(){
    rm -f "$CLASS_GROUPS_DIR/$group_name/"*
    rmdir "$CLASS_GROUPS_DIR/$group_name"
}

if [[ "$USERADMIN_ACTION" == "CREATE_GROUP" ]];
then
    create_group_dir
elif [[ "$USERADMIN_ACTION" == "DELETE_GROUP" ]]
then
    remove_group_dir
fi

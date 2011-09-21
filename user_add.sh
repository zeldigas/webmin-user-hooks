#!/bin/bash

# This is a post hook script for webmin user addition procedure
# The purpose of it --- to build a structure of user home dirs according to group
# to which user belongs.
# Script tunable parameters a situated in the begining of the script (just after
# this documentation notes). The scritp assumes that you want to make a relative 
# link from subfolder of CLASS_GROUPS_DIR to a USERS_DIR
#
# CLASS_GROUPS_DIR is a directory which contains directory groups.
# USERS_DIR is a dir where user home folders situated.
#
# Usecase assumption 1.
# a. You mount users dir to USERS_DIR and place CLASS_GROUPS_DIR in parent folder of USERS_DIR
# b. Share over NFS parent of USER_DIR.
#
# Usecase assumption 2.
# a. You USERS_DIR is a link to user homes folder (not necessary, but handy for use on server side)
# b. CLASS_GROUPS_DIR in the sampe parent folder again and is real folder
# c. NFS export USERS_DIR and CLASS_GRUPS_DIR
# d. On target pc, you mount this dirs on the same level (in the same dir) with names equal to $USERS_DIR and $CLASS_GROUPS_DIR
#
# in both this cases because of the relative link, you can access from groups dirs to user homes transparently

##### start of tunable parameters

GROUP_PATTERN="^class[1-9]+[:alpa:]*"
CLASS_GROUPS_DIR=/srv/user_dirs/groups_dir
USERS_DIR=/srv/user_dirs/user_homes

#####   End of tunable parameters
SCRIPT_DIR="$( cd "$( dirname  "$0" )" && pwd )"
source ${SCRIPT_DIR}/common.sh

function get_class_group(){
  for group_id in `echo $1 | tr "," "\n"`;
  do
      group_name=`get_group_name $group_id`
      if echo $group_name | grep -qE ${GROUP_PATTERN} - ;
      then
	  echo $group_name;
      fi
  done
}

function get_group_name() {
    echo `getent group | grep :$1: | head -n 1 | cut -f 1 -d ":"`
}

function get_user_name() {
    echo `getent passwd | grep :$1: | head -n 1 | cut -f 1 -d ":"`
}

function get_user_gecos(){
    echo "";
}

function make_link_name(){
    echo $1
}

function create_user_home_link() {
    uid=$1;
    home=$2;
    class_group=$3

    user_name=`get_user_name $uid`
    user_gecos=`get_user_gecos $uid`

    cd "$CLASS_GROUPS_DIR/$class_group/"

    relative_users_homes=`relpath "$(pwd)" "$USERS_DIR"`
    relative_home_path=$relative_users_homes/`basename $home`
    
    link_name=`make_link_name "$user_name" "$user_gecos"`

    ln -s "$relative_home_path" "$link_name"
}

user_uid=${USERADMIN_UID}
secondary_groups=${USERADMIN_SECONDARY}
user_home=${USERADMIN_HOME}


function create_links_for_user(){
    for found_value in `get_class_group $secondary_groups`;
    do
	create_user_home_link "$user_uid" "$user_home" "$found_value"
    done
}

function remove_links_for_user(){
    for found_value in `get_class_group $secondary_groups`;
    do
	rm "$CLASS_GROUPS_DIR/$found_value/$(basename $user_home)"
    done
}

if [[ "$USERADMIN_ACTION" == "CREATE_USER" ]];
then
    create_links_for_user
elif [[ "$USERADMIN_ACTION" == "DELETE_USER" ]];
then
    remove_links_for_user;
fi
#!/bin/bash

# insert documetation here
# with description of script parameters
# and passed values
#
#
#

##### start of tunable parameters

GROUP_PATTERN="^class[1-9]+[:alpa:]*"

CLASS_GROUPS_DIR=/srv/user_dirs/groups_dir
USERS_DIR=/srv/user_dirs/user_homes

#####   End of tunable parameters


user_uid=${USERADMIN_UID}
secondary_groups=${USERADMIN_SECONDARY}
user_home=${USERADMIN_HOME}

source common.sh

function get_class_group(){
  for group_id in `echo $1 | tr "," "\n"`;
  do
      if echo `get_group_name $group_id` | grep -qE ${GROUP_PATTERN} - ;
      then
	  echo $group_id;
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

for found_value in `get_class_group $secondary_groups`;
do
    create_user_home_link "$user_uid" "$user_home" "`get_group_name $found_value`"
done

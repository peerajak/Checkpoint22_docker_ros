#! /bin/bash 


echo "$(date +'[%Y-%m-%d %T]') Starting server bringup..."
roslaunch tortoisebot_firmware bringup.launch  &
sleep 3 &&
echo "$(date +'[%Y-%m-%d %T]') Starting server slam ..."
roslaunch tortoisebot_firmware server_bringup.launch


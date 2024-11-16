#! /bin/bash 

source /tortoisebot_ws/devel/setup.bash && source /tortoisebot_ws/carto_ws/devel_isolated/setup.bash 
echo "$(date +'[%Y-%m-%d %T]') Starting server bringup..."
roslaunch tortoisebot_firmware server_bringup.launch &
echo "$(date +'[%Y-%m-%d %T]') Starting slam..."
roslaunch tortoisebot_slam tortoisebot_slam.launch 





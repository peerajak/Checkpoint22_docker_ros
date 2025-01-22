#! /bin/bash 

#"sleep 5 && source /tortoisebot_ws/carto_ws/devel_isolated/setup.bash && source /tortoisebot_ws/devel/setup.bash --extend && rospack list | grep -e tortoise -e carto && printenv | grep ROS && roslaunch tortoisebot_firmware --wait server_bringup.launch"
sleep 5
source /tortoisebot_ws/carto_ws/devel_isolated/setup.bash && source /tortoisebot_ws/devel/setup.bash --extend 
rospack list | grep -e tortoise -e carto && printenv | grep ROS
echo "$(date +'[%Y-%m-%d %T]') Starting server bringup..."
roslaunch tortoisebot_firmware server_bringup.launch &
sleep 3 &&
echo "$(date +'[%Y-%m-%d %T]') Starting server slam ..."
roslaunch tortoisebot_slam tortoisebot_slam_real_no_rviz.launch


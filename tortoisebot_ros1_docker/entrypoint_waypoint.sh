#! /bin/bash 

source /tortoisebot_ws/devel/setup.bash
echo "$(date +'[%Y-%m-%d %T]') Starting rosbridge server..."
roslaunch course_web_dev_ros --wait web.launch &
echo "$(date +'[%Y-%m-%d %T]') Starting tf2_web server..." 
roslaunch course_web_dev_ros --wait tf2_web.launch  &
echo "$(date +'[%Y-%m-%d %T]') Starting action server..." 
rosrun course_web_dev_ros tortoisebot_action_server.py




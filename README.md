# Checkpoint 22: Tortoisebot on Docker

In this checkpoint, I need to do tortoisebot on docker, meaning that simulation or realrobot bring up on docker, slam on docker, waypoint on docker, and webapp on docker for ROS1, and ROS2
also I need to use docker-compose to do multiple launch of dockers in a single-shot.

## Docker Installation for NVIDIA graphic card user


After install the docker engine, use the command

```
sudo service docker start
docker context use default
```

Test Docker with Hello world image

```
sudo docker run hello-world
```
To make docker run on user without sudo

```
sudo groupadd docker
sudo usermod -aG docker $USER
sudo gpasswd -a $USER docker
newgrp docker
```

and log out from computer, and log in again

Test with docker hello world

```
docker run hello-world
```

### install Nvidia driver for docker

```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

```
sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

```
sudo apt-get update
```

```
sudo apt-get install -y nvidia-container-toolkit
```

### Configure Nvidia driver for docker for X forward

Reference: 

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt


```
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
systemctl --user restart docker
sudo nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place
```

Change The config file

```
sudo vi /etc/nvidia-container-runtime/config.toml
```
set no-cgroups to false
```
no-cgroups = false
```

Test The Nvidia driver for docker

```
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

If the sudo version works, try non-sudo version

```
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

### Test X forward

```
mkdir gimp
cd gimp
```
Create a file name Dockerfile and write the following content.

```
FROM ubuntu
RUN apt-get update
RUN apt-get install -y gimp
CMD ["gimp"]
```

then build the docker

```
docker build . -t gimp:0.1
```

Test with Sudo version

```
xhost +local:root
sudo docker run --rm -it --name gimp -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro --runtime=nvidia --gpus all gimp:0.1
```

Test with non-sudo version

```
xhost +local:root
docker run --rm -it --name gimp -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro --runtime=nvidia --gpus all gimp:0.1
```
You should see GIMP drawing app appears on your linux screen.

## Task 1 

Inside simulation_ws/src, create a new folder named tortoisebot_ros1_docker.

- Create the following Docker images:

- tortoisebot-ros1-gazebo: This Docker image will contain everything necessaary for starting the Gazebo simulation.

- tortoisebot-ros1-slam: This Docker image will contain everything necessaary for starting the mapping system.

- tortoisebot-ros1-waypoints: This Docker image will contain everything necessaary for starting the waypoints action server.

- tortoisebot-ros1-webapp: This Docker image will contain everything necessaary for starting the Tortoisebot webapp.

- Create a Docker Compose file to start up all the previous containers. This Docker Compose file will start the following systems:

- TortoiseBot Gazebo simulation

- Mapping nodes

- Waypoints Action Server

- Tortoisebot Webapp




### Info on Tortoisebot

```
tortoisebot@ubuntu:~$ uname -a
Linux ubuntu 5.4.0-1118-raspi #130-Ubuntu SMP PREEMPT Tue Oct 1 19:40:28 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux
tortoisebot@ubuntu:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.6 LTS
Release:	20.04
Codename:	focal
tortoisebot@ubuntu:~$ uname -r
5.4.0-1118-raspi
```

### How to solve this checkpoint

1. Create a docker file similar to dockerfile_tb3, and launch gazebo simulation on docker on host
2. Create a docker file similar to move_and_turn, and launch action server
3. Create a docker file to launch web app
4. Use docker-compose to launch all dockers at the same time


### 1. Gazebo Docker file

1.1. Build the image 

Terminal 1

```
docker build -f dockerfile_ros1_tortoisebot_gazebo -t tortoisebot-ros1-gazebo:v1 .
```

1.2. Test Rviz, and tortoisebot Gazebo

Terminal 1

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all tortoisebot-ros1-gazebo:v1 bash
```

   
    1.2.1 Test Rviz: inside docker run

```
    roscore &
    rviz
```

    1.2.2 Test tortoisebot gazebo: inside docker run

```
    roslaunch tortoisebot_gazebo tortoisebot_playground.launch
```

1.3 Test tortoisebot Gazebo with Sensor data in RVIZ

Terminal 1 Roscore and Gazebo

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-gazebo:v1 bash
```

Inside docker

```
    roslaunch tortoisebot_gazebo tortoisebot_playground.launch
```

Terminal 2 sensors

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-gazebo:v1 bash
```

Inside Docker

```
    roslaunch tortoisebot_slam view_sensors.launch
```

Terminal 3 Teleopt

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-gazebo:v1 bash
```

Inside Docker

```
    rosrun tortoisebot_control tortoisebot_teleop_key.py
```

1.4 Test tortoisebot Gazebo and slam

Terminal 1 Build the image

```
cp /etc/default/keyboard .
docker build -f dockerfile_ros1_tortoisebot_slam -t tortoisebot-ros1-slam:v1 .
```

Terminal 1 Roscore and Gazebo

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-gazebo:v1 bash
```

Inside docker

```
    roslaunch tortoisebot_gazebo tortoisebot_playground.launch
```

Terminal 2 Server

build the docker

```
cp /etc/default/keyboard .
docker build -f dockerfile_ros1_tortoisebot_slam -t tortoisebot-ros1-slam:v1 .
```

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-slam:v1 bash
```

Check Overlay workspace
```
rospack list | grep -e tortoisebot_ -e cartographer_ros
```

You should see packages whose name are tortoisebot and cartographer_ros

If the overlay was not successful, do

```
source /tortoisebot_ws/devel/setup.bash
source /tortoisebot_ws/carto_ws/devel_isolated/setup.bash
```

Inside Docker

```
    roslaunch tortoisebot_firmware server_bringup.launch
```

Terminal 3 Slam

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-slam:v1 bash
```

Inside Docker

```
    roslaunch tortoisebot_slam tortoisebot_slam.launch
```


## Web app

Terminal 1 Build the image

```
docker build -f dockerfile_ros1_tortoisebot_webapp -t tortoisebot-ros1-webapp:v1 .
```

then run the image

```
docker run --rm -it -p 8001:80 tortoisebot-ros1-webapp:v1 
```
-p host_port:container_port



### RUN full web control Robot

tar all the course_web_dev_ros content from the construct CP21, and place it under catkin_ws/src, and do catkin_make

Terminal 1 Playground

build (if required)

```
docker build -f dockerfile_ros1_tortoisebot_gazebo_playground -t tortoisebot-ros1-gazebo:playground .
```
run

```
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host peerajakcp22/tortoisebot-ros1-gazebo:playground
```
Terminal 2 Rosbridge 

build (if required)

```
cd ~/catkin_ws
source devel/setup.bash
catkin_make
```

run

```
SLOT_ROSBRIDGE_PORT=9090 roslaunch course_web_dev_ros web.launch
```

or using docker

build (if required)
```
docker build -f dockerfile_ros1_tortoisebot_waypoint -t tortoisebot-ros1-waypoints:v1 .
```
run

```
docker run -it --net=host peerajakcp22/tortoisebot-ros1-waypoints:v1
```

Terminal 3 Server Bring-up

build (if required)

```
docker build -f dockerfile_ros1_tortoisebot_slam_serverbringup -t tortoisebot-ros1-slam:serverbringup .
```

run

```
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host  tortoisebot-ros1-slam:serverbringup 
```


Terminal 4 Slam

build (if required)

```
docker build -f dockerfile_ros1_tortoisebot_slam_slam -t tortoisebot-ros1-slam:slam .
```

run

```
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host  tortoisebot-ros1-slam:slam
```

Terminal 5 Action Server

build (if required)

```
cd ~/catkin_ws
source devel/setup.bash
catkin_make
```

run

```
cd ~/catkin_ws
source devel/setup.bash
rosrun course_web_dev_ros tortoisebot_action_server.py
```



```
cd ~/catkin_ws
source devel/setup.bash
roslaunch robot_gui_bridge websocket.launch
```

Terminal 6  Web server

run

```
cd tortoisebot_webapp
python -m http.server 8001
```

or docker

```
docker build -f dockerfile_ros1_tortoisebot_webapp -t tortoisebot-ros1-webapp:v1 .
```

and run

```
docker run --rm -it -p 8001:80 tortoisebot-ros1-webapp:v1
```

Terminal 7 tf2_web server

```
roslaunch course_web_dev_ros tf2_web.launch
```

Open your web browser and goto http://localhost:8001


#### RUN full web control Robot with docker-compose

```
docker compose up
```

Helper commands

```
cd ~/catkin_ws
source devel/setup.bash
rostopic pub -1 /cmd_vel geometry_msgs/Twist '{linear:  {x: -0.01, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'
```

theconstructsip web video address

```
https://<theconstructsip>/stream?topic=/camera/image_raw&width=400&height=300
```

My computer's web video address

```
http://127.0.0.1:11315/stream_viewer?topic=/raspicam_node/image
```

## Task 2


### Gazebo

build (if required)

```
cp /etc/default/keyboard .
docker build -f dockerfile_ros2_tortoisebot_gazebo -t tortoisebot-ros2-gazebo:v1 .
```

Terminal 1 Roscore and Gazebo

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host tortoisebot-ros2-gazebo:v1 bash
```


### Slam

build (if required)

```
cp /etc/default/keyboard .
docker build -f dockerfile_ros2_tortoisebot_slam -t tortoisebot-ros2-slam:v1 .
```

Terminal 1 Roscore and Gazebo

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host tortoisebot-ros2-slam:v1 bash
```


### Real Robot Ros1

the OS of the tortoisebot is

```
tortoisebot@ubuntu:~/ros1_ws/src/tortoisebot/raspicam_node/launch$ uname -a
Linux ubuntu 5.4.0-1119-raspi #131-Ubuntu SMP PREEMPT Thu Oct 10 17:28:35 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux

tortoisebot@ubuntu:~$ cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.6 LTS"
```

Therefore, we need to pull this docker image from docker hub

``
docker pull  --platform linux/arm64 arm64v8/ros:noetic-ros-core-focal
```

gpg2 --gen-key
This will generate a lot of info. but the important info is GPG KEY, which is a piece of code under pub topic control-c to copy the GPG-KEY
pass init <GPG-KEY>
docker login -u peerajakcp22
(venv) peerajak@peerajak-desktop-intel:~/MyRobotics/Checkpoint22/Checkpoint22_docker_ros/tortoisebot_ros1_docker$ docker tag tortoisebot-ros1-gazebo:v1 peerajakcp22/tortoisebot-ros1-gazebo:v1
(venv) peerajak@peerajak-desktop-intel:~/MyRobotics/Checkpoint22/Checkpoint22_docker_ros/tortoisebot_ros1_docker$ docker push peerajakcp22/tortoisebot-ros1-gazebo:v1
```

build for arm64v8

```
docker buildx build --platform linux/arm64 -f dockerfile_ros1_realrobot_tortoisebot_gazebo --push -t peerajakcp22/helloworld_arm64v8:1.0 .
```

sudo docker pull peerajakcp22/helloworld_arm64v8:1.0


## Real Robot Ros1

building on PC the real robot slam docker

```
docker buildx build --platform linux/arm64 -f dockerfile_ros1_realrobot_tortoisebot_slam_slam --push -t peerajakcp22/tortoisebot-ros1-realrobot-slam:slam .
```


## Trouble shooting

if error like this

```
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

and get error

```
docker: Cannot connect to the Docker daemon at unix:///home/peerajak/.docker/desktop/docker.sock. Is the docker daemon running?.
See 'docker run --help'.

```

```
export ROS_MASTER_URI=http://192.168.3.4:11311
export ROS_HOSTNAME=192.168.3.12
```

do

```
docker context use default
```





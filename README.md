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
docker build -f dockerfile_ros1_tortoisebot_gazebo -t docker_ros1_tortoisebot_gazebo:try1 .
```

1.2. Test Rviz, and tortoisebot Gazebo

Terminal 1

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all docker_ros1_tortoisebot_gazebo:try1 bash
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
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host docker_ros1_tortoisebot_gazebo:try1 bash
```

Inside docker

```
    roslaunch tortoisebot_gazebo tortoisebot_playground.launch
```

Terminal 2 sensors

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host docker_ros1_tortoisebot_gazebo:try1 bash
```

Inside Docker

```
    roslaunch tortoisebot_slam view_sensors.launch
```

Terminal 3 Teleopt

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host docker_ros1_tortoisebot_gazebo:try1 bash
```

Inside Docker

```
    rosrun tortoisebot_control tortoisebot_teleop_key.py
```

1.4 Test tortoisebot Gazebo and slam

Terminal 1 Build the image

```
cp /etc/default/keyboard .
docker build -f dockerfile_ros1_tortoisebot_slam -t docker_ros1_tortoisebot_slam:try1 .
```

Terminal 1 Roscore and Gazebo

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host docker_ros1_tortoisebot_gazebo:try1 bash
```

Inside docker

```
    roslaunch tortoisebot_gazebo tortoisebot_playground.launch
```

Terminal 2 Server

build the docker

```
cp /etc/default/keyboard .
docker build -f dockerfile_ros1_tortoisebot_slam -t docker_ros1_tortoisebot_slam:try1 .
```

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host docker_ros1_tortoisebot_slam:try1 bash
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
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --net=host docker_ros1_tortoisebot_slam:try1 bash
```

Inside Docker

```
    roslaunch tortoisebot_slam tortoisebot_slam.launch
```


## Web app

Terminal 1 Build the image

```
docker build -f dockerfile_ros1_tortoisebot_webapp -t docker_ros1_tortoisebot_webapp:try1 .
```

then run the image

```
docker run docker_ros1_tortoisebot_webapp:try1
```



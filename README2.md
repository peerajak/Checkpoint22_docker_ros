# Checkpoint 22: Tortoisebot on Docker . Continue

```
docker pull peerajakcp22/tortoisebot-ros1-gazebo:v1
docker pull peerajakcp22/tortoisebot-ros1-waypoints:v1
docker pull peerajakcp22/tortoisebot-ros1-slam:v1
docker pull peerajakcp22/tortoisebot-ros1-webapp:v1
```


```
docker network create -d bridge --subnet=172.18.0.0/16 my-ros1-bridge-network
```

Terminal 1

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network my-ros1-bridge-network --ip 172.18.0.2 peerajakcp22/tortoisebot-ros1-gazebo:v1 bash
```

Terminal 2

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network my-ros1-bridge-network --ip 172.18.0.3 peerajakcp22/tortoisebot-ros1-waypoints:v1
```

Terminal 3

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network my-ros1-bridge-network --ip 172.18.0.4 peerajakcp22/tortoisebot-ros1-slam:v1
```

Terminal 4

```
xhost +local:root
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network my-ros1-bridge-network --ip 172.18.0.5 peerajakcp22/tortoisebot-ros1-webapp:v1
```

1. Install docker

```
sudo apt-get update
```

if error

```
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://install.husarnet.com/deb all InRelease: The following signatures were invalid: EXPKEYSIG 197D62F68A4C7BD6 Husarnet Authors <contact@husarnet.com>
W: Failed to fetch https://install.husarnet.com/deb/dists/all/InRelease  The following signatures were invalid: EXPKEYSIG 197D62F68A4C7BD6 Husarnet Authors <contact@husarnet.com>
W: Some index files failed to download. They have been ignored, or old ones used instead.
```

do

```
sudo apt-key del 197D62F68A4C7BD6
sudo rm /etc/apt/sources.list.d/husarnet.list 
sudo apt-get update
```


```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

```
sudo docker run hello-world
```

2. Install docker-compose

```
sudo curl -SL https://github.com/docker/compose/releases/download/v2.32.2/docker-compose-linux-armv7 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. Set user for docker

```
sudo groupadd docker
sudo usermod -aG docker $USER
sudo gpasswd -a $USER docker
newgrp docker
```

4. Set IP address

```
export RASPI_IPV4=<Your Ip address>
```

```
cd ~
sed -i 's/ROS_IPV6=on/ROS_IP='"$RASPI_IPV4"'/' .bashrc
sed -i 's|ROS_MASTER_URI=http://master:11311|ROS_MASTER_URI=http://$ROS_IP:11311|' .bashrc
sed -i 's/ROS_HOSTNAME=master/ROS_HOSTNAME=$ROS_IP/' .bashrc
sed -i 's/export\ ROS_IPV6=on/#export\ ROS_IPV6=on/' .bashrc
```

```
cd /home/ubuntu/ros1_ws/src/tortoisebot/tortoisebot_slam/rviz
sed -i 's|/camera/image_raw|/raspicam_node/image|' mapping.rviz sensors.rviz
sed -i 's|Transport\ Hint:\ raw|Transport\ Hint:\ compressed|' mapping.rviz sensors.rviz
sed -i 's/Fixed Frame:\ odom/Fixed Frame:\ base_link/' mapping.rviz sensors.rviz
cd ~
```

#! /bin/bash

function install_deps {
    # ----------------------------------------
    # Install pkgs required for the simulation
    # ----------------------------------------
    sudo apt-get update
    sudo apt-get install -y ros-noetic-rosbridge-suite ros-noetic-slam-gmapping

    # -----------------------------------------------------------
    # Install docker, start it and add user to the 'docker' group
    # -----------------------------------------------------------
    sudo apt-get install -y docker.io docker-compose x11-xserver-utils
    sudo service docker start
    sudo usermod -aG docker $USER
}

function point_python_to_python3 {
    # -----------------------------------------------------------
    # Some scripts refer to 'python' instead of 'python3'
    # Let's create a symbolic link 'python' pointing to 'python3'
    # -----------------------------------------------------------
    if ! [ -e /usr/bin/python ]; then
        sudo ln -sv /usr/bin/python3 /usr/bin/python
    fi
}

function main {
    install_deps
    point_python_to_python3
}

main

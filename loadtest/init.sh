#!/bin/bash

# This script sets up the virtual machine image that will then be frozen into a snapshot

sudo apt-get update

# Install docker, see https://docs.docker.com/engine/install/ubuntu/
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install maven
sudo apt install maven -y

# Clone the jitsi-torture-repository
git clone https://github.com/jitsi/jitsi-meet-torture

# Download the test video
wget -O jitsi-meet-torture/resources/FourPeople_1280x720_30.y4m https://media.xiph.org/video/derf/y4m/FourPeople_1280x720_60.y4m

# Get docker-compose file
wget -O jitsi-meet-torture/docker-compose.yml https://raw.githubusercontent.com/schul-cloud/jitsi-deployment/develop/loadtest/docker-compose.yml

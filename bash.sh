#! /bin/bash

sudo apt-get update
sudo apt-get install docker.io -y
git clone https://github.com/devopsschool-training-notes/terraform-ey-june-2021
sudo docker run -d -p 80:80 httpd
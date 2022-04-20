#! /bin/bash
sudo apt-get update
sudo apt-get install docker.io -y
git clone https://github.com/Adebusy/AlaoTest.git
sudo docker build -t myapp ./AlaoTest
sudo docker run -d -p 80:8060 myapp
sudo docker run -d -p 80:80 httpd
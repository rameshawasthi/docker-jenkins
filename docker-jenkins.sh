
#!/bin/bash
apt-get update -y
apt-get upgrade -y
#docker Install
wget https://download.docker.com/linux/ubuntu/gpg & apt-key add gpg
nano /etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
apt-get update -y
apt-get install docker-ce -y
systemctl start docker
systemctl status docker

#Create Docker Volume for Data and Log jenkins
docker volume create jenkins-data
docker volume create jenkins-log
docker volume ls

mkdir docker
nano docker/dockerfile

#install Jenkins
FROM jenkins/jenkins
LABEL maintainer="yourmail"
USER root
RUN mkdir /var/log/jenkins
RUN mkdir /var/cache/jenkins
RUN chown -R jenkins:jenkins /var/log/jenkins
RUN chown -R jenkins:jenkins /var/cache/jenkins
USER jenkins

ENV JAVA_OPTS="-Xmx8192m"
ENV JENKINS_OPTS="--handlerCountMax=300 --logfile=/var/log/jenkins/jenkins.log

cd docker
docker build -t myjenkins .

docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master --mount source=jenkins-log, target=/var/log/jenkins --mount source=jenkins-data,target=/var/jenkins_home -d myjenkins --webroot=/var/cache/jenkins/war"
docker ps
docker exec jenkins-master tail -f /var/log/jenkins/jenkins.log

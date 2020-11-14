#!/bin/bash

# os 비트 확인
getconf LONG_BIT

# 커널정보확인
uname -r

# 이전 버전 도커 삭제
sudo yum remove docker \
	     docker-client \
	     docker-client-latest \
	     docker-common \
	     docker-latest \
	     docker-latest-logrotate \
	     docker-logrotate \
	     docker-engine

# yum util 설치
sudo yum install -y yum-utils

# docker 저장소 등록
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# docker 설치
sudo yum install docker-ce docker-ce-cli containerd.io

# docker 시작
sudo systemctl start docker
sudo systemctl enable docker


# docker 설치 확인
sudo docker info
 
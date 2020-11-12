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



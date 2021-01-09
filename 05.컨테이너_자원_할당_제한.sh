#!/bin/bash
# 할당된 자원값 확인은 docker inspect | grep <Memory|Cpu> 등으로 확인

# 컨테이너 메모리 제한
docker run -d \
--memory="1g" \
--name nginx \
nginx

# 도커 자원 할당 값 변경
docker update --memory="500m" nginx

# 컨테이너 스왑메모리 제한
docker run -d \
--memory="1g" \
--memory-swap="4g" \
--name nginx \
nginx

# CPU 제한
# --cpu-shares 옵션은 컨테이너에 CPU 사용비중 가중치를 준다
# 디폴트는 1024이며 CPU할당에서 1의 비중을 나타냄 512는 0.5
docker run -d \
--cpu-shares 1024 \
--name nginx \
nginx

# 특정 cpu만 사용하도록 지정
# 다음은 컨테이너가 3번째 CPU만 사용하도록 지정
docker run -d \
--cpuset-cpus 2 \
--name nginx \
nginx

# 호스트에서 cpu 사용량을 확인하기 위해 htop 설치
yum -y install epel-release && yum install -y htop

# 컨테이너 Completely Fair Scheduler 주기(기본 100000 - 100ms)를 설정
# period는 스케줄링 주기 quota는 CPU스케줄링에 얼만큼 할당할 것인지 설정
# period가 100000 이고 quota가 25000면 컨테이너의 CPU할당 시간은 1/4됨
docker run -d \
--cpu-period=100000 \
--cpu-quota=25000 \
--name nginx \
nginx

# -cpus는 직접 cpu개수를 지정
docker run -d \
--cpus=0.5 \
--name nginx \
nginx

# Block I/O 제한 - Direct I/O에만 제한되며 Buffered I/O에는 제한 없음
# 초당 쓰기 작업 최대치가 1mb로 제한
# /dev/xvda는 디바이스 명칭이며 AWC EC2 디바이스이다 스토리지 드라이버를 사용하는 도커엔진이면 /dev/loop0로 설정
docker run -it -d \
--device-write-bps /dev/xvda:1mb \
ubuntu:latest

# IO연산에 가중치 설정 가중치가 높을 수록 수행속도가 빨라짐
docker run -it -d \
--device-write-iops /dev/xvda:5 \
ubuntu:latest
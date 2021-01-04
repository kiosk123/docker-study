#!/bin/bash

# 도커 컨테이너 실행
$ sudo docker run -i -t --name ubuntu ubuntu:latest

# 도커 이미지 커밋 - 현 상태의 컨테이너를 커밋후 이미지로 저장
# -a 옵션은 작성자 -m 옵션은 커밋 메시지를 뜻함
$ sudo docker commit -a "user" -m "initial commit" ubuntu custom_ubuntu:1.0

# 이미지 파일로 저장
$ sudo docker save -o ubuntu.tar ubuntu:latest

# 파일로 저장된 이미지 로드
$ sudo docker load -i ubuntu.tar

# 컨테이너를 파일로 저장 - 컨테이너 및 이미지에 대한 설정 정보를 저장하지는 않음
$ sudo docker export -o container.tar ubuntu

# 파일로 저장된 컨테이너 정보를 이미지로 저장
$ sudo docker import container.tar ubuntu:1.0

# kiosk123/myubuntu 지어진 도커 허브의 저장소에 이미지 올리기
$ sudo docker commit ubuntu myubuntu:1.0 # ubuntu이름의 컨테이너 이미지 저장
$ sudo docker tag myubuntu:1.0 kiosk123/myubuntu:1.0 # 이미지 이름에 저장소명이 포함되어 있어야 함으로 tag를 이용하여 이미지 이름 추가 tag [기존이미지이름][새롭게 생성될 이미지 이름]
$ sudo docker login # 도커 서버에 로그인
$ sudo docker push kiosk123/myubuntu:1.0 # 도커 저장소에 이미지 푸시

# 이미지 내려받기는 별도의 로그인 없이 pull로 받기
$ sudo docker pull kiosk123/myubuntu:1.0
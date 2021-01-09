# 2. 컨테이너 제어

## 도커 이미지 네이밍 컨벤션
- 저장소이름/이미지이름:이미지버전, 이미지이름:이미지(이름)버전
    - dockerrepo/custom:0.01, custom:latest

## 도커 엔진 버전 확인
```
docker -v
```

## 이미지 내려 받기
```
docker pull centos:7
```

## 내려 받은 이미지 목록 출력
```
docker images
```

## 내려 받은 이미지에서 컨테이너 생성 : --name 컨테이너 이름
```
# -i 상호입출력 -t tty 활성화 배시셸을 사용
docker create -i -t --name mycentos centos:7

# -d 옵션까지 추가하면 컨테이너 내부 진입하지 않아도 배시쉘은 실행시켜서 컨테이너 죽이지 않을 수 있음
docker create -i -t -d --name mycentos centos:7
```

## 생성한 컨테이너 실행
```
docker start mycentos
```

## 생성한 컨테이너 내부로 진입
```
docker attach mycentos
```

## 컨테이너 생성 - 이미지 없을시 도커 허브에서 이미지를 내려받고 실행 후 컨테이너 내부로 진입
```
# -i 상호입출력 -t tty 활성화 배시셸을 사용 (pull + create + start + attach)
docker run -i -t ubuntu:14.04
```

## 컨테이너에서 나오기 exit (ctrl + D) - 나오면서 컨테이너 종료
## 컨테이너에서 나오기 (ctrl + P, Q) - 나오면서 컨테이너를 정지시키지 않고 나옴
```
exit
```

## 실행 중인 컨테이너 목록
```
docker ps
```

## 실행 중인 컨테이너 전체 목록
```
docker ps -a
```

## 컨테이너 정보 확인
```
docker inspect mycentos
```

## 도커 컨테이너 이름변경
```
docker rename mycentos centos7
```

## 실행 중인 컨테이너 전체 중지
```
docker stop $(docker ps -a -q)
```

## 도커 컨테이너 삭제
```
docker rm centos7
```

## 실행 중인 컨테이너 강제 삭제
```
docker rm -f centos7
```

## 컨테이너 전체 삭제
```
docker container prune
docker rm $(docker ps -a -q)
```

## 도커 포트 바인딩 -p [호스트포트]:[컨테이너포트]
```
docker run -t -i -p 80:80 --name centos7 centos:7
```

## 포트 여러개 개방 및 호스트IP와포트 컨테이너 포트에 바인딩
```
docker run -t -i -p 3306:3306 -p 192.168.0.100:7777:80 --name centos7 centos:7
```

## 우분투 컨테이너에 아파치 웹서버 설치 및 기동
```
apt-get update
apt-get install apache2 -y
service apache2 start
```
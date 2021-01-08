#!/bin/bash

# .dockerignore = .gitignore랑 사용방식이 동일
vi .dockerignore

#--------------------------------------------------------------------------------------------------- 
# 도커 파일 편집
vi Dockerfile

# FROM 베이스 이미지
# MAINTAINER 이미지 작성자
# LABEL 이미지 메타 데이터 '키:값"형태로 저장됨
# RUN 컨테이너 내부에서 실행되는 명령어 - RUN 명령어가 하나의 이미지 레이어가 되기에 명령어는 && 이용해서 체이닝하여 사용하는 것을 권장한다.(이미지 용량 확대 방지)
# ADD 이미지에 파일을 추가
# WORKDIR 명령어를 실행할 디렉터리 쉘에서 CD명령어를 입력하는 것과 같은 기능
# EXPOSE: 이미지에서 노출할 포트 지정
# CMD: 컨테이너가 시작될 때마다 실행할 명령어 Dockerfile에서 딱 한번만 지정해서 사용가능

FROM ubuntu:14.04
MAINTAINER maker
LABEL "puporse"="practice"
RUN apt-get update
RUN apt-get install apache2 -y
ADD test.html /var/www/html # test.html 파일을 /var/www/html 디렉터리에 복사
WORKDIR /var/www/html
RUN /bin/bash -c "echo hello >> test2.html"
EXPOSE 80
CMD apachectl -DFOREGROUND # DFOREGROUND - 아파치 웹서버 포어그라운드로 실행


# 도커파일 빌드 docker build -t <생성할 이미지 이름> <도커파일 경로>
sudo docker build -t mybuild:1.0 .

# 도커파일 캐시를 사용하지 않고 이미지 빌드
sudo docker build --no-cache -t mybuild:1.0 .

# 캐시로 사용할 이미지를 이용하여 빌드
sudo docker build --cache-from ubuntu:14.04 -t mybuild:1.0 .

# 도커 컨테이너 생성
sudo docker run -d -p mycontainer mybuild:1.0

# 생성된 컨테이너에 바인딩 된 포트 확인
sudo docker port mycontainer

# 특정 라벨의 이미지 검색
sudo docker images --filter "label=purpose=practice"

# 특정 라벨의 컨테이너 검색
sudo docker ps --filter "label=purpose=practice"


#---------------------------------------------------------------------------------------------------
# 애플리케이션을 빌드할 때는 많은 의존성 라이브러리와 패키지가 필요하여 실제 실행 파일의 이미지는 작음에도 불구하고
# 최종 생성된 이미지는 몇백MB가 넘을 수 있음
# 도커 17.05부터는 이미지의 크기를 줄이기 위해 멀티 스태이지 빌드를 사용가능
# 하나의 도커파일안에 여러개의 FROM 이미지를 정의함으로서 빌드 완료시 최정적으로 생성될 이미지를 줄이는 방법

# 테스트를 위한 main.go 작성
package main
import "fmt"
func main() {
	fmt.Println("hello world")
}

# 도커파일 작성
# --from=0은 첫번째 FROM에서 빌드된 이미지의 최종 상태를 의미
# 첫번째 FROM 이미지에서 빌드한 /root/mainApp 파일을 
# 두번째 FROM에 명시된 이미지  alpine:latest에 복사
FROM golang
ADD main.go /root
WORKDIR /root
RUN go build -o /root/mainApp /root/main.go

FROM alpine:latest
WORKDIR /root
COPY --from=0 /root/mainApp .
CMD ["./mainApp"]

# 이미지 빌드
sudo docker build -t go_hello:1.0 .


# 멀티 스테이지 이미지 빌드시 다음과 같은 방법도 가능하다
FROM golang
ADD main.go /root
WORKDIR /root
RUN go build -o /root/mainApp /root/main.go

FROM golang
ADD main2.go /root
WORKDIR /root
RUN go build -o /root/mainApp2 /root/main2.go

FROM alpine:latest
WORKDIR /root
COPY --from=0 /root/mainApp .
COPY --from=1 /root/mainApp2 .

#---------------------------------------------------------------------------------------------------
# 기타 도커파일명령어
# 1.ENV 환경변수 지정
# ${test:-/home} :test란 이름의 환경변수 값이 설정되지 않으면 이 환경변수의 값을 /home을 사용
# ${test:+/home} :test란 이름의 환경변수 값이 설정되어 있으면 이 환경변수의 값을 /home을 사용하고 없으면 빈문자열로 설정
FROM ubuntu:14.04
ENV test /home # 환경변수명 : test, 값 : /home
WORKDIR $test
RUN touch ${test:-/home}/${test:-/home} 

# 2. VOLUME: 빌드된 이미지로 컨테이너를 생성했을 때 호스트와 공유할 컨테이너 내부의 디렉터리 설정
# 다음의 예시는 컨테이너 내부의 /home/volume 디렉터리를 호스트와 공유하도록 설정
VOLUME /home/volume # ["/home/dir", "/home/volume"] 형식으로 여러개 선언 가능

# ARG: 빌드 명령어를 실행할 때 추가로 입력을 받아 Dockerfile 내에서 사용될 변수의 값을 설정
FROM ubuntu:14.04
ARG my_arg
ARG my_arg_2=value2 # 기본값 지정
RUN touch ${my_arg}/mytouch

# 실행
sudo docker build --build-arg my_arg=/home -t myarg:0.0 .

# 3. USER: 컨테이너에서 사용될 사용자 계정의 이름이나 UID이며 컨테이너의 명령어는 해당 사용자 권한으로 실행
RUN groupadd -r author && useradd -r -g author hello
USER hello

# 4. ONBUILD: 빌드된 이미지를 기반으로 하는 이미지가 Dockerfile로 생성될 때
#             실행할 명령어를 추가한다. 
#             -> 다른 도커파일에서 이 도커파일로 생성된 이미지를 베이스로 하여 생성될때 실행되는 명령어를 지정
FROM ubuntu:14.04
RUN echo "this is onbuild test"
ONBUILD RUN echo "onbuild!" >. /onbuild_file


# 5. STOPSIGNAL: 컨테이너가 정지될 때 사용될 시스템 콜의 종류를 지정.
#                아무 것도 설정하지 않으면 기본적으로 SIGTERM 
FROM ubuntu:14.04
STOPSIGNAL SIGKILL


# 6. HEALTHCHECK: 이미지로 부터 생성된 컨테이너에서 동작하는 애플리케이션의 상태를 체크하도록 설정
#                 컨테이너 내부에서 동작 중인 애플리케이션의 프로세스가 종료되지는 않았으나 
#                 애플리케이션이 동작하고 있지 않는 상태를 방지한다.
# 다음은 1분마다 curl -f를 사용해 nginx 애플리케이션의 상태를 체크하며 3초 이상이 소요되면 이를 한번의 실패로 간주한다
# 3번이상 타임아웃이 발생하면 해당 컨테이너는 unhealthy 상태가 된다
# 단 HEALTHCHECK에서 사용되는 명령어가 curl이므로 curl을 먼저 설치해야한다

FROM nginx
RUN apt-get update -y && apt-get install curl -y

# 1분마다 헬스체크하며 3초이상 타임아웃을 한번의 실패 3번이이상 타임아웃이면 컨테이너는 unhealthy 상태
HEALTHCHECK --interval=1m --timeout=3s --retiries=3 CMD curl -f http://localhost || exit 1

# 7. SHELL : 기본 쉘 지정
SHELL ["/bin/bash"]

# 8. ADD, COPY : 카피는 로컬 파일만 이미지에 추가가능 ADD는 외부 url이나 tar파일에서도 파일 추가가능 - COPY 사용 권장

# 9. ENTRYPOINT : CMD랑 비슷하지만 ENTRYPOINT와 CMD가 둘다 있을 때 CMD는 ENTRYPOINT의 파라미터(인자)로 사용됨

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]


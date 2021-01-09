# fluentd는 데이터 포맷으로 JSON을 사용하기 때문에 AWS S3,하둡분산파일시스템, MongoDB 등에 저장가능
# 도커 엔진 컨테이너 로그를 fluentd를 통해 수집해서 Mongodb로 저장

# 몽고 디비 실행
docker run --name mongoDB -d \
-p 27017:27017 \
mongo

# entrypoint.sh와 fluent.conf 파일을 호스트 컴퓨터에 다운로드
curl https://raw.githubusercontent.com/fluent/fluentd-docker-image/master/v1.11/debian/fluent.conf > fluent.conf
curl https://raw.githubusercontent.com/fluent/fluentd-docker-image/master/v1.11/debian/entrypoint.sh > entrypoint.sh

# mongodb-plugin이 설치된 fluentd 이미지를 만들기 위한 도커 파일 작성
# 파일명은 Dockerfile
FROM fluent/fluentd:v1.11.5-debian-1.0

USER root

RUN buildDeps="make gcc g++ libc-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && gem install fluent-plugin-mongo \
 && gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

# Dockerfile을 바탕으로 이미지를 생성
docker build --tag myfluentd:mongo .

# fluent.conf 파일 작성
# access라는 컬렉션에 로그저장, 
# 저장되는 로그의 IP주소는 몽고 DB 컨테이너를 나타냄
# <match docker.**>는 로그태그가 docker로 시작시 MongoDB로 전달을 의미 
# 몽고 디비에 인증정보를 설정했다면
# flush_interval 항목 밑에 다음과 같이 사용자와 비번 명시
# user <아이디>
# password <비번>
<source>
  @type forward
</source>

<match docker.**>
  @type mongo
  database nginx
  collection access
  host 192.168.0.164
  port 27017
  flush_interval 10s
</match>

# fluentd 실행 - fluent.conf 파일 컨테이너에 마운트
docker run -d -p 24224:24224 \
-p 24224:24224/udp \
--name fluentd \
-v /home/user/fluent.conf:/fluentd/etc/fluent.conf \
-e FLUENTD_CONF=fluent.conf \
myfluentd:mongo

# 도커 서버에서 로그를 수집할 컨테이너 생성
# 그리고 브라우저로 웹서버 접속한 후 로그발생시킨다
docker run -p 80:80 -d \
--log-driver=fluentd \
--log-opt fluentd-address=192.168.0.164:24224 \
--log-opt tag=docker.nginx.webserver \
--name nginx \
nginx

# 몽고디비 컨테이너 접속
docker exec -it mongoDB /bin/bash 

> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
nginx   0.000GB

> use nginx # fluent.conf의 nginx 참조
switched to db nginx

> show collections # fluent.conf의 collections 참조
access

> db['access'].find() # fluent.conf의 collections access 참조

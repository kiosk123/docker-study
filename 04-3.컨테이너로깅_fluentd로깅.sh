# fluentd는 데이터 포맷으로 JSON을 사용하기 때문에 AWS S3,하둡분산파일시스템, MongoDB 등에 저장가능
# 도커 엔진 컨테이너 로그를 fluentd를 통해 수집해서 Mongodb로 저장

# 몽고 디비 실행
$ sudo docker run --name mongoDB -d \
-p 27017:27017 \
mongo


# fluentd 실행
$ sudo docker run -d -p 24224:24224 \
--name fluentd \
-p 24224:24224/udp \
-v /data:/fluentd/log \
fluent/fluentd:v1.3-debian-1


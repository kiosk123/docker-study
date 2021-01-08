#!/bin/bash

# 도커 컨테이너 실행
sudo docker run -i -t --name ubuntu ubuntu:latest

# 도커 이미지 커밋 - 현 상태의 컨테이너를 커밋후 이미지로 저장
# -a 옵션은 작성자 -m 옵션은 커밋 메시지를 뜻함
sudo docker commit -a "user" -m "initial commit" ubuntu custom_ubuntu:1.0

# 이미지 파일로 저장
sudo docker save -o ubuntu.tar ubuntu:latest

# 파일로 저장된 이미지 로드
sudo docker load -i ubuntu.tar

# 컨테이너를 파일로 저장(레이어가 하나만 생기므로 용량 줄이기 가능) - 컨테이너 및 이미지에 대한 설정 정보를 저장하지는 않음 
sudo docker export -o container.tar ubuntu

# 파일로 저장된 컨테이너 정보를 이미지로 저장
sudo docker import container.tar ubuntu:1.0

# kiosk123/myubuntu 지어진 도커 허브의 저장소에 이미지 올리기
sudo docker commit ubuntu myubuntu:1.0 # ubuntu이름의 컨테이너 이미지 저장
sudo docker tag myubuntu:1.0 kiosk123/myubuntu:1.0 # 이미지 이름에 저장소명이 포함되어 있어야 함으로 tag를 이용하여 이미지 이름 추가 tag [기존이미지이름][새롭게 생성될 이미지 이름]
sudo docker login # 도커 서버에 로그인
sudo docker push kiosk123/myubuntu:1.0 # 도커 저장소에 이미지 푸시

# 이미지 내려받기는 별도의 로그인 없이 pull로 받기
sudo docker pull kiosk123/myubuntu:1.0

#---------------------------------------------------------------------------------------------------

# 도커 허브가 아닌 개인 서버에 도커 사설 레지스트리 생성
# --restart : 컨테이너가 종료되었을 때  재시작하는 방법
# --restart=always : 컨테이너가 종료되면 자동 재시작
# --restart=on-failure:5 :  컨테이너가 비정상 종료(0이 아닐경우)시 컨테이너 재시작을 5번함
# --restart=unless-stopped : 컨테이너가 stop 명령어 정지되었다면 도커 엔진을 재시작해도 컨테이너는 시작안됨
sudo docker run -d --name myregistry \
-p 5000:5000 \
--restart=always \
registry:2.6

# 사설 레지스트리 정상 작동 확인
curl localhost:5000/v2/

# 사설 레지스트리에 이미지 업로드 하기전 이미지 이름을 추가 
# 형식은 ${DOCKER_HOST_IP}:5000/이미지이름:이미지태그
sudo docker tag myubuntu:1.0 192.168.0.164:5000/myubuntu:1.0

# 사설 레지스트리에 이미지 푸시 - 도커데몬은 https 사용하지 않은 레지스트리 컨테이너에 접근하지 못하도록 설정
# https를 사용하려면 인증서를 적용해 별도 설정해야되지만 지금은 테스트를 위해 이미지를 push, pull할수 있도록
# /etc/default/docker 파일 (없으면 생성) 수정 하고 다음 내용 입력
DOCKER_OPTS="--insecure-registry=192.168.0.164:5000"

# 우분투 라즈비안 기준 /lib/systemd/system/docker.service
# CentOS7 기준 /usr/lib/systemd/system/docker.service 파일을 수정하고
# EnvironmentFile과 $DOCKER_OPTS 추가

EnvironmentFile=/etc/default/docker
ExecStart=/usr/bin/dockerd $DOCKER_OPTS -H fd:// --containerd=/run/containerd/containerd.sock

# 도커 서비스 재시작
sudo systemctl restart docker

# 사설 레지스트리에 이미지 푸시
sudo docker push 192.168.0.164:5000/myubuntu:1.0

# 사설 레지스트리에서 이미지 다운 받기
sudo docker pull 192.168.0.164:5000/myubuntu:1.0

# 레지스트리 컨테이너는 생성됨과 동시에 컨테이너 내부 디렉터리에 마운트되는 도커 볼륨을 생성
# push된 이미지 파일은 이 볼륨에 저장되며 레지스트리 컨테이너가 삭제되도 볼륨은 남아있게되므로
# 레지스트리 삭제시 볼륨도 삭제하려면 다음과 같이 처리
sudo docker rm --volumes myregistry

#---------------------------------------------------------------------------------------------------
# 미리 정의된 계정으로 로그인하도록 설정함으로써 레지스트리에 접근을 제할 할 수 있음
# 레지스트리 컨테이너 자체에서 인증 정보를 설정도 가능하지만 여기서는 Nginx 서버로를 이용해서 연동하는 방식으로 처리

# 로그인 인증 기능은 보안을 적용하지 않은 레지스트리 컨테이너에서는 사용할 수 없기때문에
# 여기서는 스스로 인증한 인증서와 키를 발급함으로써 TLS를 적용하는 방법을 함께 설명

# Self-sigined ROOT 인증사 파일을 생성
mkdir certs
sudo openssl genrsa -out ./certs/ca.key 2048
sudo openssl req -x509 -new -key ./certs/ca.key -days 10000 -out ./certs/ca.crt

# 앞에서 생성한 ROOT 인증서로 레지스트리 컨테이너에 사용될 인증서를 생성
# 인증서 서명 요청 파일읜 CSR 파일을 생성하고 ROOT인증서로 새로운 인증서를 발급
# ip주소는 레지스트리 컨테이너가 존재하는 도커 호스트의 IP나 도메인 이름을 입력
sudo openssl genrsa -out ./certs/domain.key 2048
sudo openssl req -new -key ./certs/domain.key -subj /CN=192.168.0.164 -out ./certs/domain.csr
sudo echo subjectAltName = IP:192.168.0.164 > extfile.cnt
sudo openssl x509 -req -in ./certs/domain.csr -CA ./certs/ca.crt -CAkey ./certs/ca.key \
-CAcreateserial -out ./certs/domain.crt -days 10000 -extfile extfile.cnt

# htpasswd가 설치되어 있지 않으면 설치한다 - 데비안 계열은 apache2-utils
sudo yum install httpd-tools

# 다음 명령어를 입력해 레지스트리에 로그인할 때 사용할 계정과 비밀번호를 저장하는 파일을 생성한다
sudo htpasswd -c htpasswd user
sudo mv htpasswd certs/

# ./certs/nginx.conf에 레지스트리가 있는 도커 호스트 아이피를 입력한다.
upstream docker-registry {
  server registry:5000;
}
server {
  listen 443;
  server_name 192.168.0.164;
  ssl on;
  ssl_certificate /etc/nginx/conf.d/domain.crt;
  ssl_certificate_key /etc/nginx/conf.d/domain.key;
  client_max_body_size 0;
  chunked_transfer_encoding on;

  location /v2/ {
    if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
      return 404;
    }
    auth_basic "registry.localhost";
    auth_basic_user_file /etc/nginx/conf.d/htpasswd;
    add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

    proxy_pass http://docker-registry;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 900;
  }
}

# 기존에 있던 레지스트리는 혼동을 피하기 위해 삭제하고 다시 생성 (옵션)
sudo docker rm --volumes myregistry
sudo docker run -d --name myregistry --restart=always registry:2.6

# nginx 서버 컨테이너 생성
# ngix.conf, domain.crt, domain.key 파일이 존재하는 디렉터리를 -v 옵션으로 컨테이너와 공유
sudo docker run -p 443:443 -d \
--link myregistry:registry \
--name nginx \
-v /home/user/certs:/etc/nginx/conf.d \
nginx

# 컨테이너 생성되었는지 확인
sudo docker ps --format "table {[.ID]}\t{{.Image}}\t{{.Ports}}"

# 레지스트리 컨테이너에 로그인 - insecure-registry와 다른점은 뒤에 https 레지스트리가 있는 도커호스트 주소가 붙는다
sudo docker login https://192.168.0.164

# 위에서 에러 메시지가 나온다만 신뢰할 수 없는 인증서인 Self-signed 인증서를 사용했기 때무넹 에러를 출력한다
# 따라서 우리가 직접 서명한 인증서를 신뢰할 수 있는 증서 목록에 추가해야한다
# 위에서 생성한 ca.crt를 인증서 목록에 추가한다 - 우분투는 /usr/local/share/ca-certificates/
sudo cp ./certs/ca.crt /etc/pki/ca-trust/source/anchors/

# 우분투는 /usr/local/share/ca-certificates
sudo update-ca-trust

# 도커 재시작 후 Nginx 서버 컨테이너 재시작
sudo systemctl restart docker
sudo docker start nginx

# 에러메시지가 발생했을 경우 다시한번 로그인
sudo docker login https://192.168.0.164

# 레지스트리에 이미지를 push하고 pull한다 - https로 로그인시 포트번호는 안붙여도됨
sudo docker tag myubuntu:1.0 192.168.0.164/myubuntu:1.0
sudo docker push 192.168.0.164/myubuntu:1.0
sudo docker pull 192.168.0.164/myubuntu:1.0

#---------------------------------------------------------------------------------------------------
# 사설 레지스트리 RESTful API

# 1.레지스트리에 있는 이미지 목록 확인
# 1-1. https : -u 옵션으로 [아이디:비번]을 넘겨준다
sudo curl -u user:123123 https://192.168.0.164/v2/_catalog
# 1-2.http : 기본 포트 5000은 필수다
sudo curl 192.168.0.164:5000/v2/_catalog

# 2.특정 이미지의 태그 리스트 확인 ( 이미지이름/tags/list)
# 1-1. https : -u 옵션으로 [아이디:비번]을 넘겨준다 
sudo curl -u user:123123 https://192.168.0.164/v2/myubuntu/tags/list
# 1-2.http : 기본 포트 5000은 필수다
sudo curl 192.168.0.164:5000/v2/myubuntu/tags/list

# 여기서 부터는 https를 기준으로만...
# 저장된 이미지의 상세한 정보 확인 (이미지이름/manifests/태그) - 헤더에 설정안하면 manifests 1버전 형식으로 정보를 반환한다
# 버전 확인은 "schemaVersion" 프로퍼티 값을 확인
sudo curl -u user:123123 https://192.168.0.164/v2/myubuntu/manifests/1.0

# manifests 2버전 형식으로 정보를 반환 : 헤더에 값을 설정해 줘야함 -i 옵션 필수
sudo curl -u user:123123 -i \
--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
https://192.168.0.164/v2/myubuntu/manifests/1.0

# 사설 레지스트리의 이미지를 삭제하려면 사설레지스트리 생성시 이미지 삭제 활성화 환경변수를 값을 true로 설정해야한다
sudo docker run -d \
--name myregistry \
-e REGISTRY_STORAGE_DELETE_ENABLED=true \
--restart=always registry:2.6

# 그리고 삭제시에는 manifests 정보에서 출력된 manifest와 레이어 digest를 각각 삭제해줘야한다
# 순서는 메니페스트 -> 레이어 삭제 순이다
# 메니페스트 삭제는 DELETE /v2/이미지이름/menifest/<docker-content-digest> 
sudo curl -u user:123123 \
--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
-X DELETE \
https://192.168.0.164/v2/myubuntu/manifests/sha256:25fa6c673a52c3255143802aeebb6a7655ac95c934ca902a0e7170ce8659afa4

# 레이어 삭제는  DELETE /v2/이미지이름/blobs/<layers 각 digest 값> 
sudo curl -u user:123123 \
--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
-X DELETE \
https://192.168.0.164/v2/myubuntu/blobs/sha256:da7391352a9bb76b292a568c066aa4c3cbae8d494e6a3c68e3c596d34f7c75f8
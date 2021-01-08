#---------------------------------------------------------------------------------------------------
# 도커 데몬 실행

# 1. 도커 데몬 실행 및 종료 - service 명령어 사용
sudo service docker start
sudo service docker stop

# 2. 도커 데몬 실행, 활성화(재부팅되도 실행), 종료 - systemctl 명령어 사용
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl stop docker

# 3. 서비스로 실행이 아닌 명령어로 도커 데몬 실행 --insecure-registry 옵션 추가.
#    일반적으로 /etc/default/docker의 DOCKER_OPTS에 옵션을 설정 후 사용 - 06.도커이미지_도커허브_사설레지스트리.sh 참고 
sudo dockerd -H tcp://0.0.0.0:2375 --insecure-registry=192.168.0.164:5000 --tls=false

# DOCKER_OPTS에 설정할 경우
DOCKER_OPS="-H tcp://0.0.0.0:2375 --insecure-registry=192.168.0.164:5000 --tls=false"

#---------------------------------------------------------------------------------------------------
# 도커 데몬 제어

# 1. 옵션 없이 도커 데몬 실행
#    아무 옵션 없이 실행시 도커 클라이언트인 /bin/docker(/usr/bin/docker)를 위한
#    유닉스 소켓인 /var/run/docker.sock을 사용
sudo dockerd
sudo dockerd -H unix:///var/run/docker.sock # 위의 명령과 동일

# 2. Remote API를 사용하기 위한 도커 데몬 실행
#    HTTP 요청으로 원격으로 도커 데몬에 명령을 주기 위한 실행법
sudo dockerd -H tcp://0.0.0.0:2375

# 3. 유닉스 소켓과 Remote API 동시 활용을 위한 도커 데몬 실행
sudo dockerd -H unix:///var/run/docker/sock -H tcp://0.0.0.0:2375

# 4. 원격으로에서 Remote API 활성화된 도커 데몬에 명령어 전달
sudo docker -H tcp://192.168.0.164:2375 
sudo docker -H tcp://192.168.0.164:2375 images # 원격으로 도커데몬의 이미지 목록 확인
curl 192.168.0.164:2375/version --silent | python -m json.tool # curl을 이용하여 도커 버전 확인

# 4-1. 환경 변수를 설정하면 원격지 주소를 생략하고 명령어 실행 가능
export DOCKER_HOST="tcp://tcp://192.168.0.164:2375"
sudo docker version

#---------------------------------------------------------------------------------------------------
# 도커 데몬 보안 적용

# 기본적으로 도커는 보안 연결이 설정되어 있지 않음 Remote API 설정되어 있으면 누구나 원격지 IP만 있으면 도커 제어가능 -> 보안상 위험
# 도커 데몬에 TLS 보안을 적용하고 도커 클라이언트와 Remote API 클라이언트가 인증되지 않으면 도커 데몬을 제어할 수 없도록 설정한다.
# 보안적용에 사용될 파일 : ca.pem, server-cert.pem, server-key.pem, cert.pem, key.pem
# 클라이언트에서 도커 데몬에 접근할때 필요한 파일 : ca.pem, cert.pem, key.pem


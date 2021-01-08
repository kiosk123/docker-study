# 도커 데몬 실행 및 종료 - service 명령어 사용
sudo service docker start
sudo service docker stop

# 도커 데몬 실행, 활성화(재부팅되도 실행), 종료 - systemctl 명령어 사용
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl stop docker
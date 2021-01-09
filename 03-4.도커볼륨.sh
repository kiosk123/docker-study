# 도커 자체의 볼륨 기능을 활용해 데이터 공유하는 방식
# 공유할 도커 볼륨 생성
docker volume create --name myvolume

# 생성된 도커 볼륨 목록 확인
docker volume ls

# 도커 볼륨과 공유하는 컨테이너 생성
# -v [도커볼륨명]:[공유될 컨테이너 디렉터리명]
docker run -i -t --name centos7 \
-v myvolume:/home/share \
centos:7

# 컨테이너의 볼륨 실제 저장 경로 확인
docker inspect --type volume centos7
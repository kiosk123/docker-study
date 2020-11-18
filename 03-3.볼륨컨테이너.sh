# 도커 컨테이너 생성
sudo docker run -i -t \
--name volume_container \
-v /home/wordpress_db:/home/testdir \
centos:7

# 위에서 생성한 컨테이너와 볼륨공유하는 컨테이너 생성
# 호스트 /home/wordpress_db 디렉터리와
# volume_container /home/testdir 디렉터리와
# volumes_from /home/testdir 디렉터리가 공유
sudo docker run -i -t \
--name volumes_from \
--volumes-from volume_container
ubuntu:14


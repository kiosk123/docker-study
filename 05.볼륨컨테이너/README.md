# 5. 볼륨컨테이너
특정 컨테이너의 볼륨을 공유하는 컨테이너를 생성하는 방법을 알아본다.

## volume_container 컨테이너 생성
```
docker run -i -t \
--name volume_container \
-v /home/wordpress_db:/home/testdir \
centos:7
```

## 생성한 volume\_container 컨테이너와 볼륨을 공유하는   volumes\_from 컨테이너 생성

호스트의 /home/wordpress_db 디렉터리와  
volume_container 컨테이너의 /home/testdir 디렉터리와  
volumes_from 컨테이너의 /home/testdir 디렉터리가 공유  

```
docker run -i -t \
--name volumes_from \
--volumes-from volume_container
ubuntu:14
```


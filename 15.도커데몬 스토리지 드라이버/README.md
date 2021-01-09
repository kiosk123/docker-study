# 15.도커데몬 스토리지 드라이버
도커는 특정 스토리지 벡엔드 기술을 사용해 도커 컨테이너와 이미지를 저장하고 관리한다.  
도커를 설치할 때 기본적으로 사용하도록 설정된 스토리지 드라이버가 있는데,  
데비안 계열은 overlay2를 구버전의 CentOS 같은 운영체제(CentOS6 이하 버전...)는 devicemapper를 사용한다.  

```
docker info | grep "Storage Driver"
```

## 도커 데몬 스토리지 드라이버 변경
지원하는 드라이버로는 OverlayFS, AUFS, Btrfs, Devicemapper, VFS, ZFS 등이 있음  

도커가 AUFS를 기본적으로 사용하도록 설정된 우분투에서 다음과 같이 도커 데몬을 실행하면  
별도의 Devicemapper 컨테이너와 이미지를 사용하므로 AUFS에서 사용했던 이미지와 컨테이너를 사용할 수 없음  
Devicemmapper 파일은 /var/libdocker/devicemapper에 저장되며,  
AUFS 드라이버 또한 /var/lib/docker/aufs에 저장된다.

스토리지 드라이버 선택은 개발하는 컨테이너 애플리케이션 및 개발 환경에 따라 다르다.  
레드햇 계열 이면 OverlayFS(overlay-커널 3.18이상, overlay2-커널 4.0이상)를, 안정성이 우선이면 Btrfs가 좋을 수 있다.  
무조건 좋은 스토리지 드라이버라는 것은 없기 때문에 상황에 따라 드라이버의 장단점을 감안해 선택해야한다.  
권장은 overlay2(커널 4.0이상)가 권장이다. [참고](https://docs.docker.com/storage/storagedriver)

```
# 도커 데몬 스토리지 드라이버 변경
dockerd --storage-driver=devicemapper

# DOCKER_OPTS를 이용한 변경도 가능
DOCKER_OPS="--storage-driver=devicemapper"
```

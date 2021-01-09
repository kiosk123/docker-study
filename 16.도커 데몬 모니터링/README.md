# 16. 도커 데몬 모니터링

## 모니터링 명령어
### events
도커 데몬에 어떤 일이 일어나고 있는지 실시간 스트림을 로그를 출력

```
docker events
```

--filter 'type=값' 을 사용해 원하는 범위의 정보만 출력할 수 있다.  
옵션 값은 container, image, volume, network, plugin, daemon이다.  

```
docker events --filter 'type=image'
```


### stats

실행 중인 모든 컨테이너의 자원 사용량을 스트림으로 출력한다.  

```
docker stats

# 스트림이 아닌 한번 말 출력
docker stats --no-stream
```

### system df

도커에서 사용하고 있는 이미지, 컨테이너, 로컬 볼륨의 총 개수 및 사용 중인 개수, 크기, 삭제함으로써 확보가능한 공간 출력

```
docker system df
```
----------------

## CAdvisor
구글이 만든 컨테이너 모니터링 도구로, 컨테이너로서 간단히 설치할 수 있고, 컨테이너별 실시간 자원 사용량 및 도커 모니터링 정보 등을 시각화해서 보여준다.  
[CAdvisor 깃허브](https://github.com/google/cadvisor)  
[CAdvisor 도커허브](https://hub.docker.com/r/google/cadvisor/)  

CAdvisor는 단일 호스트 모니터링으로 적합하지만 도커 클러스터에서는 쿠버네티스나 스웜 모드같은 오케스트레이션 툴을 설치한 뒤에  
프로메테우스, InfluxDB 등을 이용해 여러 호스트의 데이터를 수집하는 것이 일반적이다

```
# 디렉터리 경로:ro 는 마운트된 디렉터리 경로를 read only로 엑세스 하겠다는 뜻, :rw는 read write를 의미
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest
```

위 명령어로 컨테이너가 생성되면 8080포트로 접속하면 된다.
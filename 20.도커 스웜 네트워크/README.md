# 20. 도커 스웜 네트워크
스웜 모드는 여러 개의 도커 엔진에 같은 컨테이너를 분산해서 할당하기 때문에 각 도커 데몬의 네트워크가 하나로 묶인, 네트워크 풀이 필요하다.  
서비스를 외부로 노출했을 때 어느 노드로 접근하더라도 해당 서비스의 컨테이너에 접근할 수 있게 라우팅 기능이 필요하다.  
이러한 네트워크 기능은 스웜 모드가 자체적으로 지원하는 네트워크 드라이버를 통해 사용할 수 있다.

```
# 도커가 지원하는 네트워크 목록 출력
docker network ls

NETWORK ID     NAME              DRIVER    SCOPE
c28785c45378   bridge            bridge    local
51503a5f6408   docker_gwbridge   bridge    local
a171e9c9d2e0   host              host      local
c9szigkw4iou   ingress           overlay   swarm
fdc7a7ed4219   none              null      local

```

도커가 지원하는 네트워크 드라이버에서 docker_gwbridge와 ingress 네트워크가 생성된 것을 볼 수 있다.  
docker_gwbridge 네트워크는 스웜에서 오버레이 네트워크를 사용할 때 이용되며, ingress 네트워크는 로드 밸런싱과 라우팅 메시에 사용된다.

## ingress 네트워크
ingress 네트워크는 스웜 클러스터를 생성하면자동으로 등록되는 네트워크로서 스웜 모드를 사용할 때만 유효하다.  
서비스 생성시 -p 옵션으로 노출할 서비스의 포트를 지정해야한다.

```
docker network ls | grep ingress
c9szigkw4iou   ingress           overlay   swarm
```

ingress 네트워크를 확인하기 위해 임의로 할당된 16진수를 출력하는 PHP파일이 들어있는 웹서버 클러스터를 구성한다.

```
docker service create --name hostname \
-p 80:80 \
--replicas=4 \
alicek106/book:hostname
```

스웜 모드로 생성된 모든 서비스의 컨테이너가 외부로 노출되기 위해 무조건  ingress를 사용해야하는 것은 아니다.  
ingress를 사용하지 않고 호스트의 특정 포트를 사용하도록 설정할 수 있다.  

다음은 호스트 8080번 포트를 직접 컨테이너의 80번 포트에 연결하는 예이다

```
docker service create --name web \
--publish mode=host,target=80,published=8080,protocol=tcp \
nginx
```

하지만 ingress 네트워크를 사용하지 않고 서비스를 외부로 노출할 경우 어느 호스트에서 컨테이너가 생성될지 알 수 없어 포트 및 서비스 관리가 어렵다는 단점이 있다.  
그래서 가급적이면 ingress 네트워크를 사용하여 서비스를 노출하는 것이 좋다


## 오버레이 네트워크
사용자 정의 오버레이 네트워크를 생성할 수 있다.

```
docker network create \
--subnet 10.0.9.0/24 \
-d overlay \
myoverlay
```

위와 같이 생성된 네트워크는 swarm모드에서만 사용할 수 있기 때문에 일반 적인 컨테이너에서는 이 네트워크를 사용할 수 없다.  
일반적인 컨테이너에서 **docker run --net** 명령어로 스웜 모드의 오버레이 네트워크를 사용하려면 네트워크 생성시 **--attachable**을 추가해야한다.

```
docker network create -d overlay \
--attachable 
myoverlay2
```

docker service create 명령어에 --network 옵션을 이용하면 오버레이 네트워크를 사용해 서비스에 적용하여 컨테이너를 생성할 수 있다.

```
docker service create --name overlay_service \
--network myoverlay
--replicas 2 \
alicek106/book:hostname
```

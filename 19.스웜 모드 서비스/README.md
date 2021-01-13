# 19. 스웜 모드 서비스
도커의 제어단위는 컨테이너이지만 스웜 모드에서는 제어 단위가 컨테이너가 아닌 서비스다.  
서비스는 같은 이미지에서 생성된 컨테이너의 집합이며, 서비스를 제어하며 해당 서비스 내의 컨테이너에 같은 명령이 수행된다.  
서비스 내에 컨테이너는 1개 이상 존재할 수 있으며, 컨테이너들은 각 워커 노드와 매니저 노드에 할당된다.  
이러한 컨테이너들을 태스크라고 한다.  

서비스는 내 컨테이너들의 이미지를 일괄적으로 업데이터해야 할 때 컨테이너들의 이미지를 순서대로 변경해 서비스 자체가 다운되는 시간 없이 컨테이너의 업데이트를 진행할 수 있다.  

### 서비스 생성
서비스를 제어하는 도커 명령어는 전부 매니저 노드에서만 사용 가능하다.  
서비스 내의 컨테이너는 detached 모드로 사용해 동작할 수 있는 이미지로 사용해야한다. 그렇치 않으면 컨테이너 내부 프로세스가 없기 때문에 컨테이너가 정지될 것이고,  
스웜 매니저는 서비스의 컨테이너에 장애가 생긴 것으로 판단해 컨테이너를 계속 반복해서 생성할 것이다.

다음은 ubuntu 이미지를 이용해 hello world를 계속 출력하는 서비스를 생성하는 명령이다.

```
docker service create \
 ubuntu:latest \
 /bin/bash -c "while true; do echo hello world; sleep 1; done"

```

Private 저장소 또는 레지스트리에서 이미지를 받아올 경우, 매니저 노드에서 로그인 한 뒤 **--with-registry-auth** 옵션을 추가하면,  
워커 노드에서 별도로 로그인을 하지 않아도 이미지를 받아올 수 있다.

```
docker service create --with-registry-auth \
...
```

### 생성된 서비스 목록 확인

```
docker service ls
```

서비스 정보를 자세하게 확인 - 서비스내 컨테이너의 목록, 상태, 컨테이너가 할당된 노드 위치 확인

```
docker service ps r7aaaalfp9ga
```

### 생성된 서비스 삭제
```
docker service rm dreamy_jemison
```


## 웹서비스 제어
### 웹 서비스 생성
**--replica** 옵션을 이용해 서비스 내의 컨테이너 갯수를 설정하고 컨테이너의 80번 포트를 각 노드의 80번 포트로 서비스를 생성한다.

```
# 두 노드에서 컨테이너가 생성 된다고 해서 웹서비스 접속시 컨테이너가 생성된 두 노드로 접속해야 하는 것은 아님
# 클러스터링이 되었기 때문에 어느 노드로 접속하더라도 서비스를 이용할 수 있음
docker service create --name myweb \
 --replicas 2 \
 -p 80:80 \
 nginx
```

### 웹 서비스 스케일링
실시간으로 컨테이너 갯수를 늘리거나 줄일 수 있다.  
노드가 3개이고 컨테이너는 4개인데 포트를 80번으로 노출되면 나머지 컨테이너 하나는 80이 아닌 다른 포트로 호스트와 연결되며 80번 포트로 들어온 요청은 리다이렉트된다
```
myweb 서비스의 컨테이너를 4개로 늘림
docker service scale myweb=4
```

### global 서비스 생성
스웜 클러스터 내에서 사용할 수 있는 모든 노드에 컨테이너를 반드시 하나씩 생성한다  
스웜 클러스터를 모니터링하기 위한 에이전트 컨테이너등을 생성할 때 유용하다

```
docker service create --name global_web \
 --mode global \
 nginx
```

### 장애복구
복제 모드로 설정된 서비스의 컨테이너가 정지하거나  특정 노드가 다운되면 스웜 매니저는 새로운 컨테이너를 생성해 자동으로 복구한다  
다음은 명령어를 통해 컨테이너를 하나 삭제한다

```
# 현재 노드의 컨테이너 조회
docker ps --filter is-task=true # 스웜 모드 서비스의 컨테이너만 조회

docker rm -f  global_web.wjmfluntjugt0eofvllbrs7x6
```

### 서비스 롤링 업데이트 - 1
서비스 특정 부분을 업데이트 할 수 있다.  
먼저 1.10버전의 이미지로 서비스를 생성한다.

```
docker service create --name myweb2 \
--replicas 3 \
nginx:1.10
```

서비스의 특정 부분 중에서 이미지를 업데이트한다.

```
docker service update \
--image nginx:1.11 \
myweb2
```

### 서비스 롤링 업데이트 - 2
서비스를 생성할 때 롤링 업데이트 주기, 업데이트를 동시에 진행할 컨테이너의 개수, 업데이트에 실패했을 때 어떻게 할 것인지 설정할 수 있다.  
다음은 각 컨테이너 레플리카를 10초 단위로 업데이트하며 업데이트 작업을 한 번에 2개의 컨테이너에 수행한다는 것을 의미한다.  
이를 설정하지 않으면 주기 없이 차례대로 컨테이너를 한 개씩 업데이트 한다.

```
docker service create \
--replicas 4 \
--name myweb3 \
--update-delay 10s \
--update-parallelism 2 \
nginx:1.10
```

업데이트 도중 오류가 발생하면 롤링 업데이트를 중지하는 것이 기본 정책이지만,  
**--update-failure-action** 인자의 값을 continue로 지정해 업데이트 중 오류가 발생해도 계속 롤링 업데이를 진행할 수 있다.

```
docker service create --name myweb4 \
--replicas 4 \
--update-failure-action continue \
nginx:1.10
```

### 서비스 롤링 업데이트 롤백
서비스 롤링 업데이트 전 또는 후로 돌리는 롤백도 가능하다.

```
docker service rollback myweb2
```


### 서비스 롤링 업데이트 설정 확인

```
docker service inspect --pretty myweb3
```
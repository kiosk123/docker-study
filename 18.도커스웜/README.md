# 18. 도커 스웜
도커 1.16 부터 지원되는 스웜모드는 매니저 노드이면서 워커노드(도커 서버)를과 다른 노드(도커 서버)들 클러스터링 하기 위한 기술이다  
이번 실습에서는 매니저 노드는 하나만 사용하지만 실제 운영환경에서 클러스러링을 구성할 시 특정 매니저 노드가 다운되어도 정상적으로 클러스를 유지할 수 있도록 매니저 노드도 다중화하는 것을 권장한다.  

## 도커 스웜 모드 클러스터 구축
스웜 매니저 192.168.0.164  
워커(스웜) 노드1 192.168.0.166  
워커(스웜) 노드2 192.168.0.173  

### 스웜 클러스터 시작
스웜 노드로 사용할 서버에서 스웜 클러스터를 시작한다.  
**--advertise-addr**에는 다른 도커 서버가 매니저 노드에 접근하기 위한 IP 주소를 입력한다.

```
docker swarm init --advertise-addr 192.168.0.164
```
스웜 매니저는 기본적으로 2377번 포트를 사용한다.  
노드사이의 통신에 7946/tcp, 7946/udp 포트를, 스웜이 사용하는 네트워크인 ingress 오버레이 네트워크에 4789/tcp, 4789/udp 포트를 사용한다.  
그렇기 때문에 방화벽에서 위 포트들을 차단하지 않도록 설정해야한다.  

매니저 노드에 2개 이상의 네트워크 인터페이스 카드가 있을 경우 어느 IP 주소로 매니저에 접근해야 할지 다른 노드에 알려줄 필요가 있다.  
명령을 실행하고 나면 다음의 출력창이 나오는 데 이때 **docker swarm join** 명령어는 새로운 워크 노드를 스웜 클러스터에 추가할 때 사용된다.  
**--token** 옵션에 사용된 토큰 값은 새로운 노드를 해당 스웜 클러스터에 추가하기 위한 비밀키다 .  

```
Swarm initialized: current node (n0r53dlnpnxsytlv1up3yqbm6) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4zwr902lspk73m5686ipzmesrl6f3k62wqyn2k7ue2vgmgmz46-crt3t8hj2atd1r9da6e55kmsa 192.168.0.164:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

### 워커 노드 추가
각 워커 노드로 추가할 서버에 접속 후 워커 노드를 추가하기 위한 토큰을 사용해 새로운 워크 노드를 추가한다.  
워커 노드로 추가하기 위해서는 매니저 노드에서 실행 후 출력되었던 **docker swarm join** 명령어와 **--token** 값을 이용한다.

```
docker swarm join --token SWMTKN-1-4zwr902lspk73m5686ipzmesrl6f3k62wqyn2k7ue2vgmgmz46-crt3t8hj2atd1r9da6e55kmsa 192.168.0.164:2377
```

**정상 적으로 스웜 클러스터에 추가되었는지 확인**하기 위해 매너저 노드에서 다음 명령어를 실행한다

```
docker node ls

# *가 붙어 있는 것이 현재 서버를 뜻함
ID                            HOSTNAME        STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
n0r53dlnpnxsytlv1up3yqbm6 *   centos7         Ready     Active         Leader           20.10.2
au02soww7m747zqwrjufgpzyn     docker-swarm2   Ready     Active                          20.10.2
f8rw7ux73fz2ov1yrs06gszgx     ubuntu          Ready     Active                          20.10.2

```

### 매니저 노드
매니저 노드는 일반적인 매니저 역할을 하는 노드와 리더 역할을 하는 노드로 나뉜다.  
리더 매너저는 모든 매너저 노드에 대한 데이터 동기화와 관리를 담당하므로 항상 작동할 수 있는 상태여야한다.  
리더 매니저의 서버가 다운되는 등의 장애가 생기면 매니저는 새로운 리더를 선출하는데 이때 [Raft Consensus 알고리즘](https://raft.github.io)을 사용한다.  
실습에서는 한 개의 매니저 노드만 조재하고 이 매니저 노드에서 스웜 클러스터가 생성됐으므로 해당 노드가 리더가 된다.


### 매니저 노드 및 워커 노드 추가
**새로운 매니저 노드를 추가하려면 매니저 노드를 위한 토큰을 사용해 docker swarm join 명령어를 사용한다.**  
**매니저 노드를 추가하기 위한 토큰은 docker swarm join-token manager를 통해 확인가능하다.**  
**워커 노드를 추가하기 위한 토큰은 docker swarm join-token worker를 통해 확인가능하다.** 

```
# 매니저 노드 추가를 위한 토큰 확인
 docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4zwr902lspk73m5686ipzmesrl6f3k62wqyn2k7ue2vgmgmz46-ee7gqkx6f37kf8bp71lgfc44q 192.168.0.164:2377
```

### 스웜 토큰 갱신
스웜 클러스터에 노드를 추가하는 토큰이 공개되면 누구든지 해당 스웜 클러스터에 노드를 추가할 수 있기 때문에 보안을 위해서 주기적으로 토큰을 갱신하는 것이 좋다  
토큰을 갱신하려면 **swarm join** 명령어에 **--rotate** 옵션을 추가하고 변경할 토큰의 대상을 입력한다.  
**이 작업은 매니저 노드에서만 수행**할 수 있다.  

```
# 매니저 노드를 추가하는 토큰을 변경하는 예
docker swarm join-token --rotate manager
```

### 스웜 노드 삭제
**워커 노드를 다운**시킬 때는 워커 노드에서 다음 명령어를 입력한다.

```
docker swarm leave
```

**다운 시킨 워커 노드를 삭제**할 때는 매니저 노드에서 다음 명령어를 입력한다.

```
docker node rm <노드ID>
```

**매니저 노드를 스웜 클러스터에서 삭제**하면 해당 매니저 노드에 저장돼 있던 클러스터의 정보도 삭제되므로 주의해야한다.(매니저 노드가 특히 단 하나만 존재할 경우)  
다음은 매니저 노드를 삭제하는 명령어다

```
docker swarm leave --force
```

### 스웜 노드 변경
매니저 노드에서 명령어를 실행한다.
**워커 노드를 매니저 노드로 변경** 

```
docker node promote <노드ID>
```

**매니저 노드를 워커 노드로 변경**

```
docker node demote <노드ID>
```
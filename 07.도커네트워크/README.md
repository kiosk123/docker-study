# 7. 도커 네트워크
도커는 컨테이너에 외부와의 네트워크를 제공하기 위해 컨테이너마다 가상 네트워크 인터페이스를 생성한다.  
이때 생성되는 인터페이스명은 veth로 시작한다.  
ifconfig으로 확인시 veth 인터페이스는 컨테이너 갯수만큼 생성된 것을 확인 할 수 있다.  
ifconfig으로 확인되는 docker0 인터페이스는 veth 인터페이스와 바인딩되어 호스트의 eth0 인터페이스와 연결해주는 브릿지 역할을 한다.  

## 도커에서 사용가능한 네트워크 목록 확인
```
docker network ls
```

## 도커 네트워크 인터페이스 정보 확인
Config 항목에서 디폴트로 docker0 브릿지 사용확인 가능

```
docker network inspect bridge
```

## bridge(브릿지) 네트워크
docker0가 아닌 사용자 정의 브리지를 새로 생성해 각 컨테이너에 연결하는 네트워크 구조  
컨테이너는 연결된 브리지를 통해 외부와 통신가능  
새로운 브리지 네트워크 **mybridge** 를 생성한다.  

```
docker network create --driver bridge mybridge
```

컨테이너를 실행하면서 생성한 **mybridge** 네트워크를 사용하게 함

```
docker run -i -t --name mynetwork_container \
--net mybridge \
ubuntu:14.04
```

브리지 타입의 네트워크와 run 명령어의 --net-alias 옵션을 함께 쓰면,  
특정 호스트 이름으로 컨테이너 여러개에 접근할 수 있다.  
**다음은 network_alias_container1, network_alias_container2, network_alias_container3를 생성하고, common_bridge라는 호스트 이름을 할당하였다 **  

```
docker run -i -t -d --name network_alias_container1 \
--net mybridge \
--net-alias common_bridge \
ubuntu:14.04

docker run -i -t -d --name network_alias_container2 \
--net mybridge \
--net-alias common_bridge \
ubuntu:14.04

docker run -i -t -d --name network_alias_container3 \
--net mybridge \
--net-alias common_bridge \
ubuntu:14.04
```

inspect로 각 컨테이너의 IP를 확인

```
docker inspect network_alias_container1 | grep IPAddress
docker inspect network_alias_container2 | grep IPAddress
docker inspect network_alias_container3 | grep IPAddress
```

생성한 ** network_alias_container1, network_alias_container2, network_alias_container3** 컨테이너에 네트워크로 접근할 컨테이너를 생성한다. 

```
docker run -i -t --name alias_ping \
--net mybridge \
ubuntu:14.04
```

생성한 **alias_ping** 컨테이너 내부에서 **common_bridge**라는  호스트 이름으로 ping을 요청한다.  
반복 실행 할때마다 응답하는 컨테이너(라운드 로빈으로 응답)가 달라지는 것을 확인가능하다

```
ping -c 3 common_bridge
```

생성한 **alias_ping**컨테이너 내부에서 **commong_bridge** 호스트에서 반환하는  IP 리스트 순서를 확인하자  
명령을 실행 할때 마다 응답하는 IP 순서가 매번 다른것(라운드 로빈으로 응답)을 확인 가능하다

```
apt-get update
apt-get install dnsutils
dig common_bridge
```

생성된 사용자 정의 네트워크인 **mybridge**에 컨테이너 끊고 다시 연결하기
- ** 논 네트워크, 호스트 네트워크 등과 같은 특별한 네트워크 모드에서는 생성한 네트워크에 연결 끊고다시 연결하기를 사용할 수 없음 **

```
docker network disconnect mybridge mynetwork_container
docker network connect mybridge mynetwork_container
```

## 네트워크 생성시 서브넷, 게이트웨이, IP할당 범위를 설정

```
docker network create --driver=bridge \
--subnet=172.72.0.0/16 \
--ip-range=172.72.0.0/24 \
--gateway=172.72.0.1 \
my_custom_network
```

## host(호스트) 네트워크
호스트 드라이버의 네트워크는 별도로 생성할 필요없이 기존의 host라는 이름의 네트워크 사용  
컨테이너를 실행하면서 host 네트워크를 사용하도록 설정한다  
host로 설정된 컨테이너의 네트워크는 도커가 실행되는 호스트 컴퓨터의 네트워크와 동일한 네트워크 구조를 가진다. (호스트 컴퓨터의 네트워크 환경을 그대로 사용가능)  
그렇기 때문에 컨테이너 내부의 애플리케이션을 별도의 포트 포워딩 없이 바로 서비스 가능하다.  

```
docker run -t -i --name network_host \
--net host \
ubuntu:14.04
```

## none(논) 네트워크
none은 말 그대로 아무런 네트워크를 쓰지 않는 것을 뜻한다.  
다음과 같이 컨테이너를 생성하면 외부와의 연결이 단절된다.

```
docker run -i -t --name network_none \
--net none \
ubuntu:14.04
```

## 컨테이너 네트워크
**--net** 옵션으로 **container**를 입력하면 다른 컨테이너의 네트워크 네임스페이스 환경을 공유할 수 있다.  
공유되는 속성은 내부 IP,. 네트워크 인터페이스의 맥(MAC) 주소 등이다.  
**--net** 옵션의 값으로 **container:[다른 컨테이너의 ID]**와 같이 입력한다.

```
# network_container_1 컨테이너 생성
docker run -i -t -d --name network_container_1 ubuntu:14.04

# network_container_1과 네트워크 공유
docker run -i -t -d --name network_cotainer_2 \
--net container:network_container_1 \
ubuntu:14.04
```

## MacVLAN 네트워크
호스트의 네트워크 인터페이스 카드를 가상화해 물리 네트워크 환경을 컨테이너에 동일하게 제공  
MacVLAN 사용시 컨테이너는 물리 네트워크상에서 가상의 맥 주소를 가지며 해당 네트워크에 연결된 다른 장치와의 통신이 가능해짐  
왜냐하면 기본 IP대역인 172.17.X.X 대신 네트워크 장비의 IP를 할당 받는다.  
**다만 MacVLAN을 사용하는 컨테이너는 기본적으로 호스트와 통신이 불가능하고**  
할당 받은 IP의 네트워크 장비 IP대역을 사용하는 다른 서버 및 컨테이너들과 통신이 가능

## MacVLAN 네트워크 생성
**-d** 드라이버로 MacVLAN 사용 명시  
  
**--subnet** 컨테이너가 사용할 네트워크 정보  
  
**--ip-range** MacVLAN을 생성하는 호스트에서 사용할 컨테이너의 IP범위  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MacVLAN네트워크간 IP범위가 겹치지 않도록 설정 필요  
  
**--gateway** 네트워크 게이트웨이  
  
**-o** 네트워크의 추가적인 옵션  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;macvlan_mode=bridge를 브릿지모드로하고  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;네트워크 인터페이스의 부모 인터페이스를 eth0로 지정한다. 
      
```
docker network create \
-d macvlan \
--subnet=192.168.0.0/24 \
--ip-range=192.168.0.64/28 \
--gateway=192.168.0.1 \
-o macvlan_mode=bridge \
-o parent=eth0 my_macvlan
```

# macvlan을 사용하는 컨테이너 생성

```
docker run -it --name c1 --hostname c1 \
--network my_macvlan ubuntu:14.04

ip a # 컨테이너 안에서 설정된 아이피를 확인
```
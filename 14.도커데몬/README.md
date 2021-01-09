## 도커 데몬 실행

### 도커 데몬 실행 및 종료 - service 명령어 사용
```
service docker start
service docker stop
```

###  도커 데몬 실행, 활성화(재부팅되도 실행), 종료 - systemctl 명령어 사용
```
systemctl start docker
systemctl enable docker
systemctl stop docker
```

### 서비스로 실행이 아닌 명령어로 도커 데몬 실행 --insecure-registry 옵션 추가.
일반적으로 /etc/default/docker의 **DOCKER_OPTS**에 옵션을 설정 후 사용 - [12.도커이미지, 도커허브, 사설레지스트리리 참고](https://github.com/kiosk123/docker-study/tree/master/12.%EB%8F%84%EC%BB%A4%EC%9D%B4%EB%AF%B8%EC%A7%80%2C%20%EB%8F%84%EC%BB%A4%ED%97%88%EB%B8%8C%2C%20%EC%82%AC%EC%84%A4%EB%A0%88%EC%A7%80%EC%8A%A4%ED%8A%B8%EB%A6%AC)  

```
dockerd -H tcp://0.0.0.0:2375 --insecure-registry=192.168.0.164:5000 --tls=false
```

### DOCKER_OPTS에 설정할 경우
```
DOCKER_OPS="-H tcp://0.0.0.0:2375 --insecure-registry=192.168.0.164:5000 --tls=false"
```

---------------------------------------------------------------------------------------------------
## 도커 데몬 제어

### 옵션 없이 도커 데몬 실행
아무 옵션 없이 실행시 도커 클라이언트인 /bin/docker(/usr/bin/docker)를 위한 유닉스 소켓인 /var/run/docker.sock을 사용

```
dockerd
dockerd -H unix:///var/run/docker.sock # 위의 명령과 동일
```

### Remote API를 사용하기 위한 도커 데몬 실행
HTTP 요청으로 원격으로 도커 데몬에 명령을 주기 위한 실행법

```
dockerd -H tcp://0.0.0.0:2375
```

### 유닉스 소켓과 Remote API 동시 활용을 위한 도커 데몬 실행

```
dockerd -H unix:///var/run/docker/sock -H tcp://0.0.0.0:2375
```

### 원격으로에서 Remote API 활성화된 도커 데몬에 명령어 전달

```
docker -H tcp://192.168.0.164:2375 
docker -H tcp://192.168.0.164:2375 images # 원격으로 도커데몬의 이미지 목록 확인
curl 192.168.0.164:2375/version --silent | python -m json.tool # curl을 이용하여 도커 버전 확인
```

### 환경 변수를 설정하면 원격지 주소를 생략하고 명령어 실행 가능

```
export DOCKER_HOST="tcp://tcp://192.168.0.164:2375"
docker version
```

--------------------------------------------------------------------------------------------------

## 도커 데몬 보안 적용
기본적으로 도커는 보안 연결이 설정되어 있지 않음 Remote API 설정되어 있으면 누구나 원격지 IP만 있으면 도커 제어가능 -> 보안상 위험  
도커 데몬에 TLS 보안을 적용하고 도커 클라이언트와 Remote API 클라이언트가 인증되지 않으면 도커 데몬을 제어할 수 없도록 설정한다.  
보안을 적용할 때 사용될 파일은 5개 : ca.pem, server-cert.pem, server-key.pem, cert.pem, key.pem  
도커데몬에 적용할 파일 : ca.pem, server-cert.pem, server-key.pem  
클라이언트에서 도커 데몬에 접근할때 필요한 파일 : ca.pem, cert.pem, key.pem

### 서버 측 파일 생성
#### 인증서에 사용될 키 생성

```
mkdir keys
cd keys
openssl genrsa -aes256 -out ca-key.pem 4096
```
#### 공개(public) 키 생성
```
openssl req -new -x509 -days 10000 -key ca-key.pem -sha256 -out ca.pem
```

#### 서버 측에서 사용될 키를 생성(private) 키 생성
```
openssl genrsa -out server-key.pem 4096
```

#### 서버측에서 사용될 인증서를 위한 인증 요청서 파일을 생성 CN=<외부에서 접속가능한 도커호스트의 아이피 | 도메인이름>
```
openssl req -subj "/CN=192.168.0.164" -sha256 -new -key server-key.pem -out server.csr
```

#### 접속에 사용될 IP주소를 extfile.cnf 파일로 저장한다. IP:<외부에서 접속가능한 도커호스트의 아이피 | 도메인이름>
```
echo subjectAltName = IP:192.168.0.164,IP:127.0.0.1 > extfile.cnf
 ```
 
#### 서버 측의 인증서 파일을 생성한다.
```
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

### 클라이언트 측에서 사용할 파일 생성 (서버측 파일을 생성한 호스트에서 생성해야함 헷갈리지 말것)
#### 클라이언트 측의 키 파일과 인증 요청 파일을 생성하고, extfile.cnf 파일에 extnededKeyUsage 항목을 추가한다
```
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > extfile.cnf
```

#### 클라이언트 측의 인증서를 생성한다.
```
openssl x509 -req -days 30000 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf
```

#### ls 명령어로 ca.pem, server-cert.pem, server-key.pem, cert.pem, key.pem이 다 존재하는 지 확인한다.
```
ls
anaconda-ks.cfg  ca.pem  cert.pem    extfile.cnf           key.pem          server-key.pem
ca-key.pem       ca.srl  client.csr  initial-setup-ks.cfg  server-cert.pem  server.csr
```

#### 생성된 파일의 쓰기 권한을 삭제해 읽기 전용 파일로 만든다.
```
chmod -v 0400 ca-key.pem key.pem server-key.pem ca.pem server-cert.pem cert.pem
```

#### 파일을 효과적으로 관리하기 위해 디렉터리에 생성한 파일을 한곳에다 몰아둔다
```
cp {ca,server-cert,server-key,cert,key}.pem ~/.docker
```
#### /etc/default/docker 파일 내용 설정
도커 Remote API는 보안이 적용되어 있지않으면 2375를 보안이 적용되어 있으면 2376을 사용하도록 하자

```
DOCKER_OPTS="--tlsverify --tlscacert=/root/.docker/ca.pem --tlscert=/root/.docker/server-cert.pem --tlskey=/root/.docker/server-key.pem -H=0.0.0.0:2376 -H unix:///var/run.docker.sock"
```

#### CentOS7 기준 /usr/lib/systemd/system/docker.service 파일 수정
 우분투 라즈비안 기준 /lib/systemd/system/docker.service  
EnvironmentFile과 $DOCKER_OPTS 추가 - (설정 안되어 있을 경우)

```
EnvironmentFile=/etc/default/docker
ExecStart=/usr/bin/dockerd $DOCKER_OPTS -H fd:// --containerd=/run/containerd/containerd.sock
```

#### 서버에서 생성한 클라이언트 인증 관련 파일을 클라이언트의 홈디렉터리로 복사
복사한 파일을 클라이언트의 /root/.docker로 옮긴다.

```
scp ca.pem user@192.168.0.173:~
scp cert.pem user@192.168.0.173:~
scp key.pem user@192.168.0.173:~

mkdir /root/.docker
mv {ca,cert,key}.pem /root/.docker
```

#### 클라이언트에서 원격지 서버로 원격지 도커 엔지의 버전을 확인하는 명령을 전달한다.
접속시 ca.pem, key.pem, cert.pem 파일이 필요하기 때문에 ca.pem, key.pem, cert.pem이 위치한  디렉터리 경로를 옵션으로 넘겨야한다.

```
docker -H 192.168.0.164:2376 \
--tlscacert=/root/.docker/ca.pem \
--tlscert=/root/.docker/cert.pem \
--tlskey=/root/.docker/key.pem \
--tlsverify version
```

#### DOCKER_CERT_PATH와 DOCKER_TLS_VERIFY 환경변수를 설정한다.
매번 도커로 인증 관련 옵션을 넣는 것은 귀찮기 때문에 인증 관련 옵션을 생략하기 위해 설정한다

```
export DOCKER_CERT_PATH="/root/.docker" # 도커 클라이언트 인증파일이 존재하는 경로
export DOCKER_TLS_VERIFY=1 # TLS 인증을 사용할지 여부
```

적용하고 나면 인증관련 옵션없이도 원격으로 도커 제어가 가능하다

```
docker -H 192.168.0.164:2376 version
```

#### curl로 보안이 적용된 도커 데몬의 Remote API를 사용하려면 다음과 같이 플래그를 설정한다

```
 curl https://192.168.0.164:2376/version \
 --cert ~/.docker/cert.pem \
 --key ~/.docker/key.pem \
 --cacert ~/.docker/ca.pem
```


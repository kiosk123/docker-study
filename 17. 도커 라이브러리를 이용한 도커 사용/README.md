# 17. 도커 라이브러리를 이용한 도커 사용

docker -H <호스트 IP| 도메인> 을 통해서 도커를 원격으로 제어하는 방법이 있지만,  
애플리케이션이 수행해야 할 작업이 많거나 애플리케이션 초기화등 복잡한 과정이 포함돼 있다면,  
도커 제어 라이브러리를 사용해 해결 할 수 있다.

라이브러리 [목록](https://docs.docker.com/engine/api/sdk/)  

## 자바 라이브러리를 이용한 도커 제어
- 개발 환경
    - java 1.8
    - gradle 6.6
    - docker-client 라이브러리
- 선행 작업
    - 인증 없이 Remote API를 사용하기 위해 **DOCKER_OPTS="-H tcp://0.0.0.0:2375"** 가 설정되어야함
    - DOCKER_OPTS에 http와 https 설정이 되어 있어야함
    - 클라이언트 인증 파일이 프로젝트 폴더에 위치해 있어야 함 - 프로젝트 폴터의 keys 디렉터리에 위치
- 프로젝트 폴더
    - docker-client-project
        - DockerInfoMain - HTTP로 도커 정보 읽어오기 
        - DockerTLSConnectMain - HTTPS로 도커 접속
        - DockerTLSControlMain - HTTPS로 도커에 접속 하여 컨테이너를 생성하기
# 3. 컨테이너 간 연동
* 워드프레스 컨테이너가 mysql 컨테이너를 참조할 수 있도록 설정한다
* 참조방향은 워드프레스 컨테이너 -> mysql 컨테이너
* 컨테이너 실행 순서는 참조방향의 역인 mysql 컨테이너 -> 워드프레스 컨테이너  

## mysql(데이터베이스) 컨테이너 실행
- -e 옵션으로 컨테이너 내부의 환경변수값 설정
- -i, -t 옵션과 달리 -d 옵션은 Detached 모드로 컨테이너 실행
    - Detached 모드는 컨테이너를 백드라운드에서 동작하는 애플리케이션으로 실행하게 함
    - **Detached 모드는 컨테이너는 컨테이너 내부에서 반드시 터미널을 차지하는 포그라운드 프로그램이 실행되어야함**
    
```
docker run -d \
	--name wordpressdb \
	-e MYSQL_ROOT_PASSWORD=password \
	-e MYSQL_DATABASE=wordpress \
	mysql:5.7
```

## 워드 프레스 컨테이너 실행
- --link(현재 deprecated)는 컨테이너를 IP가 아닌 이름으로 접근하여 연결
    - 여기서는 wodpressdb를 mysql호스트명을 사용하여 접근함
    - --link 옵션으로 인해서 컨테이너의 실행순서의 의존성도 생김

```
docker run -d \
	--name wordpress \
	-e WORDPRESS_DB_PASSWORD=password \
	--link wordpressdb:mysql \
	-p 80:80 \
	wordpress
```

## Detach 모드 컨테이너에서 배시 셸사용
```
docker exec -i -t wordpressdb /bin/bash
```

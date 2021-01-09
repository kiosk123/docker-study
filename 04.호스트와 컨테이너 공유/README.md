# 4. 호스트와 컨테이너 공유

## -v 옵션
* -v [호스트디렉터리]:[컨테이너디렉터리] 옵션으로  호스트와 컨테이너 디렉터리 연결하여 컨테이너 실행
* -v 옵션은 여러개 사용가능하며(-p 옵션과 사용법 동일) 파일 공유도 가능하다

```
docker run -d \
	--name wordpressdb \
	-e MYSQL_ROOT_PASSWORD=password \
	-e MYSQL_DATABASE=wordpress \
	-v /home/user/wordpress_db:/var/lib/mysql \
	mysql:5.7
```
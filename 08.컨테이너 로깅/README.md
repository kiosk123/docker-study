# 8. 컨테이너 로깅

## 컨테이너 생성
```
docker run -d --name mysql \
-e MYSQL_ROOT_PASSWORD=1234 \
mysql:5.7
```

## 컨테이너 내부에서  발생하는 출력확인
``` 
docker logs mysql
```

## 로그의 마지막 두줄만 출력
```
docker logs --tail 2 mysql
```

## 유닉스 시간으로 특정 시간이후의 로그를 출력
```
docker logs --since 1474765979 mysql
```

## 컨테이너에서 실시간으로 출력되는 내용을 확인 (-t옵션은 타임스탬프 출력)
```
docker logs -f -t mysql
```

## 컨테이너 파일 로깅
기본적으로 컨테이너 로그는 JSON형태로 도커내부에 저장  
파일은 다음과 같은 경로에 컨테이너 ID로 시작하는 파일명으로 저장됨  
**/var/lib/docker/containers/${CONTAINER_ID}/${CONTAINER_ID}-json.log**  

**--log-opt** 에 추가 적인 파라미터를 넘기는 것으로 로깅 옵션을 지정해 줄 수 있음  
**--log-opt max-size ** : 컨테이너 실행시 json 로그 파일의 최대 크기 지정  
**--log-opt max-file ** : 컨테이너 실행시 로그 파일의 개수 지정 

```
docker run -it \
--log-opt max-size=10k --log-opt max-file=3 \
--name log-test ubuntu:14.04
```

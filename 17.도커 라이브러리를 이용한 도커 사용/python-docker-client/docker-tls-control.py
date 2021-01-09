# -*- coding: utf-8 -*

import docker
import os

tls_config = docker.tls.TLSConfig(
    client_cert=('./keys/cert.pem', './keys/key.pem')
)

# 도커 호스트에서 파이썬 실행시  'unix://var/run/docker/sock'로 설정
client = docker.DockerClient(base_url='https://192.168.0.164:2376', tls=tls_config)

# nginx 이미지를 로 컨테이너를 만든다 - mynginx라는 이름으로 컨테이너 생성
# 자바와는 다르게 이미지가 없으면 이미지 다운받고 컨테이너 생성까지 처리한다
# ports={컨테이너:호스트}
container = client.containers.run('nginx', detach=True,  name="mynginx", ports={'80/tcp':80})
print("Created container is : {} {}".format(container.name, container.id))

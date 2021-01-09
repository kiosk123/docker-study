# -*- coding: utf-8 -*

import docker
import os

tls_config = docker.tls.TLSConfig(
    client_cert=('./keys/cert.pem', './keys/key.pem')
)

# 도커 호스트에서 파이썬 실행시  'unix://var/run/docker/sock'로 설정
client = docker.DockerClient(base_url='https://192.168.0.164:2376', tls=tls_config)
print(client.info())

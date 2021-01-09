# -*- coding: utf-8 -*

import docker

# 도커 호스트에서 파이썬 실행시  'unix://var/run/docker/sock'로 설정
client = docker.DockerClient(base_url='unix://var/run/docker/sock')
client.info()
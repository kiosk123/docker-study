# rsyslog, syslog는 기본적인 로깅이므로 별도 UI 제공 x
# 별도 UI를 활용하려면 https://loganalyzer.adiscon.com/, https://logentries.com/ 활용


# syslog로 컨테이너를 로깅하도록 설정 - 컨테이너는 syslogtest를 출력 후 바로 종료
docker run -d --name syslog_container \
--log-driver=syslog \
ubuntu:14.04 \
echo syslogtest

# syslog에 로깅 되었는지 확인 - centos7에는 /var/log/messages를 확인
tail /var/log/syslog

# syslog를 원격에 저장하는 방법의 하나인 rsyslog를 써서 중앙 컨테이너로 로그를 저장할 수 있다.
# rsyslog 서비스가 시작되도록 설정된 컨테이너를 구동하고, 클라이언트 호스트에서 컨테이너를 생성해
# 서버의 rsyslog 컨테이너에 로그를 저장한다.- 

# rsyslog 컨테이너를 생성
docker run -i -t \
-h rsyslog \
--name rsyslog_server \
-p 514:514 -p 514:514/udp \
ubuntu:14.04

# 컨테이너 내부의 rsyslog.conf 파일 열어서 syslog 서버 구동시키는 항목의 주석 제거
vi /etc/rsyslog.conf

# provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# provides TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514

# 컨테이너의 rsyslog 서비스 재시작
service rsyslog restart

# 클라이언트 호스트에서 아래의 명령어를 입력해 컨테이너를 생성한다.
# 그리고 컨테이너 로그를 기록하기 위한 간단한 echo 명령을 실행한다.
# 여기서는 tcp로 방법으로 활성화 했지만 rsyslog.conf에 udp설정을 해서
# udp로도 사용할 수도 있다.
docker run -i -t \
--log-driver=syslog \
--log-opt syslog-address=tcp://192.168.0.164:514 \
--log-opt tag="mylog" \
ubuntu:14.04

echo test

# 다시 rsyslog 컨테이너에 접속해 /var/log/syslog에 로그가 기록되었는지 확인한다.
docker attach rsyslog_server

tail /var/log/syslog

# --log-opt로 syslog-facility를 쓰면 로그가 저장될 파일을 바꿀수 있다.
# 로그를 생성하는 주체(클라이언트)에 따라 로그를 다르게 저장하는 것으로
# 여러 애플리케이션에서 수집되는 로그를 분류할 수 있다.
# 기본적으로 daemon으로 설정 되어있지만 kern, user, mail 등 다른 facility도 사용가능하다
docker run -i -t \
--log-driver=syslog \
--log-opt syslog-address=tcp://192.168.0.164:514 \
--log-opt tag="maillog" \
--log-opt syslog-facility="mail" \
ubuntu:14.04

# rsyslog 서버 컨테이너의 /var/log 디렉터리에 facility에 해당하는 로그파일이 
# 생성된다. 위에서는 mail을 사용했으므로 mail.log라는 파일이 생성된다.

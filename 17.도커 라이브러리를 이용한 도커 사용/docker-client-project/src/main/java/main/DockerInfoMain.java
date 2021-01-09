package main;

import com.spotify.docker.client.DefaultDockerClient;
import com.spotify.docker.client.DockerClient;
import com.spotify.docker.client.exceptions.DockerException;

/**
 * 도커에 연결해서 도커 데몬 정보 가져오기
 * @author USER
 *
 */
public class DockerInfoMain {
    
    //private static final String DOCKER_IP = "unix:///var/run/docker.sock" //이클립스가 도커호스트에서 실행될 경우
    private static final String DOCKER_IP = "http://192.168.0.164:2375";
    
    public static void main(String[] args) {
        DockerClient dc = new DefaultDockerClient(DOCKER_IP);
        try {
            System.out.println(dc.info());
        } catch (DockerException | InterruptedException e) {
            e.printStackTrace();
        }
        dc.close();
    }
}

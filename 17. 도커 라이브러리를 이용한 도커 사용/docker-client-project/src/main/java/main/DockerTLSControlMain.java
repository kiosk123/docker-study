package main;

import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.spotify.docker.client.DefaultDockerClient;
import com.spotify.docker.client.DockerCertificates;
import com.spotify.docker.client.DockerClient;
import com.spotify.docker.client.exceptions.DockerCertificateException;
import com.spotify.docker.client.exceptions.DockerException;
import com.spotify.docker.client.messages.ContainerConfig;
import com.spotify.docker.client.messages.ContainerCreation;
import com.spotify.docker.client.messages.HostConfig;
import com.spotify.docker.client.messages.PortBinding;

/**
 * 원격으로 nginx 컨테이너를 생성한다.
 * @author USER
 *
 */
public class DockerTLSControlMain {

    private static final String DOCKER_HTTPS_IP = "https://192.168.0.164:2376";

    public static void main(String[] args) {
        try (DockerClient dc = new DefaultDockerClient.Builder()
                .uri(DOCKER_HTTPS_IP)
                .dockerCertificates(new DockerCertificates(Paths.get("keys"))) // key파일들이 위치한 경로
                .build()) {
            
         
         List<PortBinding> hostPorts = new ArrayList<>();
         
         //컨테이너의 포트와 연결할 호스트의 IP 주소와 포트는 0.0.0.0:80
         hostPorts.add(PortBinding.of("0.0.0.0", 10080));
         
         Map<String, List<PortBinding>> portBindings = new HashMap<>();
         
         // hostPort는 컨테이너의 80/tcp와 연결
         portBindings.put("80/tcp", hostPorts);
         
         HostConfig hostConfig = HostConfig.builder()
                                           .portBindings(portBindings)
                                           .build();
         
         //컨테이너  정보 설정 - nginx 이미지가 이미 받아져 있는 상태라고 가정
         ContainerConfig containerConfig = ContainerConfig.builder()
                                                          .image("nginx")
                                                          .hostConfig(hostConfig)
                                                          .attachStderr(false)
                                                          .attachStdin(false)
                                                          .attachStdout(false)
                                                          .build();

        //mynginx 이름으로 컨테이너 생성 
        ContainerCreation container = dc.createContainer(containerConfig, "mynginx");
        
        String id = container.id();
        System.out.println(id);
        
        // 컨테이너 시작
        dc.startContainer(id);
         
        } catch (DockerCertificateException | DockerException | InterruptedException e) {
            e.printStackTrace();
        }

    }

}

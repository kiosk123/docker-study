package main;

import java.io.File;
import java.nio.file.Paths;

import com.spotify.docker.client.DefaultDockerClient;
import com.spotify.docker.client.DockerCertificates;
import com.spotify.docker.client.DockerClient;
import com.spotify.docker.client.exceptions.DockerCertificateException;
import com.spotify.docker.client.exceptions.DockerException;

/**
 * 도커 데몬에 TLS로 연결
 * @author USER
 *
 */
public class DockerTLSConnectMain {

    private static final String DOCKER_HTTPS_IP = "https://192.168.0.164:2376";
    
    public static void main(String[] args) {
        
        try ( DockerClient dc = new DefaultDockerClient
                .Builder()
                .uri(DOCKER_HTTPS_IP)
                .dockerCertificates(new DockerCertificates(Paths.get("keys"))) //key파일들이 위치한 경로
                .build()){
            
            try {
                System.out.println(dc.info());
            } 
            catch (DockerException | InterruptedException e) {
                e.printStackTrace();
            }
            
        } 
        catch (DockerCertificateException e) {
            e.printStackTrace();
        }
    }
}

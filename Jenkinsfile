node () {
    env.DOCKER_TAG = '1.19'

    stage ('Checkout SCM') {
        git url: 'https://github.com/Kapil987/assignment1.git', branch: 'main'
        }
    stage ('Docker Build') {
        docker.withRegistry( 'https://registry.hub.docker.com', 'docker_logins' )
            {
                def customImage = docker.build("kapil0123/nginx-statefulset:${DOCKER_TAG}")
                customImage.push()             
            }
        }

        stage ('Deploy') {
            withKubeConfig([credentialsId: 'kube-config', serverUrl: 'https://172.31.19.158:8443']) {
            sh 'kubectl apply -f nginx-deploy.yml'
            }
        }
}
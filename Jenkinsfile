```groovy
pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        DOCKERHUB_USERNAME = 'sriharini242002'
        IMAGE_NAME = 'devops-dashboard'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Source') {
            steps {
                sh '''
                    test -f app.py
                    test -f Dockerfile
                    test -f requirements.txt
                    test -d templates
                    test -d static
                    echo "All required files are present."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
                      -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Verify Image') {
            steps {
                sh 'docker image inspect ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x
                        echo "$DOCKER_TOKEN" | docker login \
                          --username "$DOCKER_USER" \
                          --password-stdin

                        docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Docker image built and pushed to Docker Hub.'
        }

        failure {
            echo 'FAILED: Check the Jenkins Console Output.'
        }
    }
}
```

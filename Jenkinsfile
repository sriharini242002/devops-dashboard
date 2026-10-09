
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'devops-dashboard'
        IMAGE_TAG  = "${BUILD_NUMBER}"
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
                    echo "Checking project files..."
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
                      -t ${IMAGE_NAME}:${IMAGE_TAG} \
                      -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Verify Image') {
            steps {
                sh 'docker image inspect ${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Source checked and Docker image built.'
        }

        failure {
            echo 'FAILED: Check the Jenkins Console Output for details.'
        }
    }
}
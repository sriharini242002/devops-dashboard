
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        AWS_REGION    = 'us-west-2'
        EKS_CLUSTER   = 'devops-dashboard-eks'
        K8S_NAMESPACE = 'devops-dashboard'
        APP_NAME      = 'devops-dashboard'
        CONTAINER_NAME = 'flask-app'
        IMAGE_NAME    = 'sriharini242002/devops-dashboard'
    }

    stages {

        // 1. Download source code from GitHub
        stage('Checkout') {
            steps {
                checkout scm

                sh '''
                    echo "Repository checked out successfully"
                    git log -1 --oneline
                '''
            }
        }

        // 2. Basic Python syntax validation
        stage('Test Application') {
            steps {
                sh '''
                    set -eu

                    echo "Checking Python syntax..."

                    python3 -m compileall -q app.py

                    echo "Python syntax check passed"
                '''
            }
        }

        // 3. Build a versioned Docker image
        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu

                    docker build \
                      --pull \
                      -t "${IMAGE_NAME}:${BUILD_NUMBER}" \
                      -t "${IMAGE_NAME}:latest" \
                      .

                    echo "Docker image built successfully"
                '''
            }
        }

        // 4. Push images to Docker Hub
        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x

                        echo "$DOCKER_TOKEN" | docker login \
                          --username "$DOCKER_USER" \
                          --password-stdin

                        docker push "${IMAGE_NAME}:${BUILD_NUMBER}"
                        docker push "${IMAGE_NAME}:latest"

                        docker logout
                    '''
                }
            }

            post {
                always {
                    sh 'docker logout || true'
                }
            }
        }

        // 5. Configure kubectl to connect to EKS
        stage('Configure EKS') {
            steps {
                sh '''
                    set -eu

                    aws sts get-caller-identity

                    aws eks update-kubeconfig \
                      --region "$AWS_REGION" \
                      --name "$EKS_CLUSTER"

                    echo "Checking application namespace..."

                    kubectl get namespace "$K8S_NAMESPACE"
                '''
            }
        }

        // 6. Deploy the exact image built by this Jenkins run
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    set -eu

                    echo "Updating Kubernetes Deployment..."

                    kubectl set image \
                      deployment/"$APP_NAME" \
                      "$CONTAINER_NAME"="${IMAGE_NAME}:${BUILD_NUMBER}" \
                      --namespace "$K8S_NAMESPACE"

                    echo "Waiting for rollout..."

                    kubectl rollout status \
                      deployment/"$APP_NAME" \
                      --namespace "$K8S_NAMESPACE" \
                      --timeout=180s
                '''
            }
        }

        // 7. Verify the deployment
        stage('Verify Deployment') {
            steps {
                sh '''
                    set -eu

                    echo "Deployment status:"
                    kubectl get deployment "$APP_NAME" \
                      --namespace "$K8S_NAMESPACE"

                    echo "Pods:"
                    kubectl get pods \
                      --namespace "$K8S_NAMESPACE"

                    echo "Services:"
                    kubectl get services \
                      --namespace "$K8S_NAMESPACE"

                    echo "Deployed image:"
                    kubectl get deployment "$APP_NAME" \
                      --namespace "$K8S_NAMESPACE" \
                      -o jsonpath='{.spec.template.spec.containers[?(@.name=="flask-app")].image}'

                    echo ""
                    echo "Deployment pipeline completed successfully."
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Docker image built, pushed, and deployed to EKS.'
        }

        failure {
            echo 'FAILED: Check the stage logs above to identify the issue.'
        }

        always {
            echo "Jenkins build number: ${BUILD_NUMBER}"
        }
    }
}


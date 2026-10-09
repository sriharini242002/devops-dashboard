

pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        AWS_REGION     = 'us-west-2'
        EKS_CLUSTER    = 'devops-dashboard-eks'
        K8S_NAMESPACE  = 'devops-dashboard'
        APP_NAME       = 'devops-dashboard'
        CONTAINER_NAME = 'flask-app'
        IMAGE_NAME     = 'sriharini242002/devops-dashboard'

        // Monitoring runs on the monitoring EC2 instance.
        // These localhost URLs require MobaXterm SSH tunnels
        // on your laptop.
        PROMETHEUS_URL = 'http://localhost:9090'
        GRAFANA_URL    = 'http://localhost:3000'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'

                checkout scm

                sh '''
                    echo "Latest Git commit:"
                    git log -1 --oneline
                '''
            }
        }

        stage('Validate Python Application') {
            steps {
                echo 'Validating Python source code...'

                sh '''
                    python3 --version
                    python3 -m compileall -q app.py
                    echo "Python validation completed successfully."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the DevOps Dashboard Docker image...'

                sh '''
                    docker build --pull \
                        -t "${IMAGE_NAME}:${BUILD_NUMBER}" \
                        -t "${IMAGE_NAME}:latest" .
                '''
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Pushing Docker images to Docker Hub...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
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
                    sh 'docker logout >/dev/null 2>&1 || true'
                }
            }
        }

        stage('Configure EKS Access') {
            steps {
                echo 'Configuring AWS and Kubernetes access...'

                sh '''
                    aws --version
                    kubectl version --client

                    echo "Checking AWS identity..."
                    aws sts get-caller-identity

                    echo "Updating kubeconfig..."
                    aws eks update-kubeconfig \
                        --region "$AWS_REGION" \
                        --name "$EKS_CLUSTER"

                    echo "Checking Kubernetes namespace..."
                    kubectl get namespace "$K8S_NAMESPACE"
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo 'Deploying the new application image to EKS...'

                sh '''
                    kubectl set image \
                        deployment/"$APP_NAME" \
                        "$CONTAINER_NAME"="${IMAGE_NAME}:${BUILD_NUMBER}" \
                        --namespace "$K8S_NAMESPACE"

                    kubectl rollout status \
                        deployment/"$APP_NAME" \
                        --namespace "$K8S_NAMESPACE" \
                        --timeout=180s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying the application deployment...'

                sh '''
                    echo "Deployment status:"
                    kubectl get deployment "$APP_NAME" \
                        --namespace "$K8S_NAMESPACE"

                    echo ""
                    echo "Application pods:"
                    kubectl get pods \
                        --namespace "$K8S_NAMESPACE" \
                        -o wide

                    echo ""
                    echo "Kubernetes services:"
                    kubectl get services \
                        --namespace "$K8S_NAMESPACE"

                    echo ""
                    echo "Deployed application image:"
                    kubectl get deployment "$APP_NAME" \
                        --namespace "$K8S_NAMESPACE" \
                        -o jsonpath='{.spec.template.spec.containers[?(@.name=="flask-app")].image}'

                    echo ""
                '''
            }
        }

        stage('Print Application and Monitoring URLs') {
            steps {
                script {
                    echo ''
                    echo '=================================================='
                    echo '       DEVOPS DASHBOARD - ACCESS DETAILS'
                    echo '=================================================='

                    // Retrieve the LoadBalancer DNS dynamically.
                    def lbDns = sh(
                        script: '''
                            kubectl get service "$APP_NAME" \
                                --namespace "$K8S_NAMESPACE" \
                                -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
                        ''',
                        returnStdout: true
                    ).trim()

                    if (lbDns) {
                        echo "Application URL : http://${lbDns}"
                        echo "Health Check    : http://${lbDns}/health"
                        echo "Database Test   : http://${lbDns}/db-test"
                        echo "Prometheus Metrics Endpoint: http://${lbDns}/metrics"
                    } else {
                        echo 'Application LoadBalancer DNS is not available yet.'
                        echo 'Check: kubectl get svc -n devops-dashboard'
                    }

                    echo ''
                    echo '=================================================='
                    echo '       PROMETHEUS AND GRAFANA MONITORING'
                    echo '=================================================='
                    echo "Prometheus URL  : ${env.PROMETHEUS_URL}"
                    echo "Grafana URL     : ${env.GRAFANA_URL}"
                    echo ''
                    echo 'IMPORTANT: Prometheus and Grafana are accessed'
                    echo 'through MobaXterm SSH tunnels on your laptop.'
                    echo 'Keep the tunnels running while accessing them.'
                    echo 'These localhost URLs are not public endpoints.'
                    echo '=================================================='
                    echo ''
                }
            }
        }
    }

    post {
        success {
            echo '''
            ==========================================
              PIPELINE COMPLETED SUCCESSFULLY
            ==========================================
            Docker image pushed.
            EKS deployment rollout completed.
            Application and monitoring URLs printed.
            ==========================================
            '''
        }

        failure {
            echo '''
            ==========================================
              PIPELINE FAILED
            ==========================================
            Check the stage logs above to identify
            the error before rerunning the pipeline.
            ==========================================
            '''
        }

        always {
            echo 'Jenkins pipeline execution finished.'
        }
    }
}
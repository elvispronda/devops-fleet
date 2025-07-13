// ci-pipeline.groovy - Triggered on every push to 'main'. Its job is to produce a secure, tested artifact.
pipeline {
    agent any
    environment {
        // Use the AWS ECR registry. More secure and efficient than Docker Hub.
        ECR_REGISTRY = "${env.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPO_NAME = "devops-fleet"
        // The image tag is dynamic and traceable to the build that created it.
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') { /* ... */ }
        
        stage('Unit Tests') {
            steps {
                // Example: sh 'pytest'
                echo "Running unit tests..."
            }
        }

        stage('SonarQube Analysis & Quality Gate') {
            steps {
                // This stage ensures code quality and security standards are met *before* building.
                withSonarQubeEnv('MySonarQubeServer') {
                    sh 'sonar-scanner ...'
                }
                // CRITICAL: This pauses the pipeline to check the SonarQube results.
                // If the Quality Gate fails (e.g., new bugs, low coverage), the pipeline aborts.
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Build & Push Secure Image to ECR') {
            steps {
                script {
                    def fullImageName = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    
                    // Build the multi-stage Dockerfile
                    sh "docker build -t ${fullImageName} -f backend/Dockerfile ."
                    
                    // Login to AWS ECR using IAM roles (no static credentials needed on Jenkins)
                    sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                    // Push the built image to our private registry.
                    sh "docker push ${fullImageName}"
                }
            }
        }

        stage('Vulnerability Scan with Trivy') {
            steps {
                // Scan the EXACT image we just pushed for HIGH or CRITICAL vulnerabilities.
                // The '--exit-code 1' flag will fail the pipeline if any are found.
                // This prevents vulnerable code from ever being marked as 'deployable'.
                sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
            }
        }
    }
    post {
        success {
            // On full success, automatically trigger the CD pipeline, passing the new image tag.
            echo "CI Successful. Triggering CD pipeline for image: ${IMAGE_TAG}"
            build job: 'cd-pipeline', parameters: [string(name: 'IMAGE_TAG', value: IMAGE_TAG)]
        }
        failure {
            // Notify on failure.
        }
    }
}
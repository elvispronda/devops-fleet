// cd-pipeline.groovy - Deploys a specific, verified image tag to production.
pipeline {
    agent any
    parameters {
        // This pipeline requires an IMAGE_TAG to know what to deploy.
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'The image tag to deploy (e.g., build-123)')
    }
    stages {
        stage('Manual Approval for Production') {
            // A critical human checkpoint. No code goes to production without explicit approval.
            // This prevents accidental deployments.
            timeout(time: 1, unit: 'HOURS') {
                input message: "Deploy image tag '${params.IMAGE_TAG}' to the Production EKS cluster?", ok: "Deploy to Production"
            }
        }

        stage('Deploy to EKS Production') {
            steps {
                script {
                    def fullImageName = "${env.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/devops-fleet:${params.IMAGE_TAG}"
                    
                    // Use Jenkins secrets management for the kubeconfig file.
                    withKubeconfig([credentialsId: 'eks-kubeconfig-credentials']) {
                        // Use Helm for templating and managing the release.
                        // This is much better than raw 'kubectl apply'.
                        // The helm command updates the Kubernetes deployment, triggering a safe rolling update.
                        sh """
                            helm upgrade --install backend-app ./k8s/charts/backend \
                                --namespace fleet-production \
                                --set image.repository=${ECR_REGISTRY}/devops-fleet \
                                --set image.tag=${params.IMAGE_TAG}
                        """
                        // Verify the deployment completed successfully.
                        sh "kubectl rollout status deployment/backend-deployment -n fleet-production"
                    }
                }
            }
        }
    }
}
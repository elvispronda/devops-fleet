// monitoring-deploy-pipeline.groovy - Manages the lifecycle of our monitoring stack.
// This is run manually when we need to install or upgrade Prometheus/Grafana.
pipeline {
    agent any
    stages {
        stage('Deploy/Upgrade Monitoring Stack via Helm') {
            steps {
                withKubeconfig([credentialsId: 'eks-kubeconfig-credentials']) {
                    sh """
                        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                        helm repo update
                        
                        # Use Helm to deploy the entire stack from a community-maintained chart.
                        # We override default settings using our own values file from our Git repo.
                        helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
                            --namespace monitoring --create-namespace \
                            -f ./monitoring/prometheus-values.yml
                    """
                }
            }
        }
    }
}
#!/bin/bash
set -x
source .jenkins-scripts/jenkins-common.sh

# Ensure working directory is root
cd "${ROOT_DIR}"

# Install the optional kfp package
sudo pip3 install kfp

# Wait for the kubeflow pipeline service to be ready, and then wait another 30 seconds for other random Kubeflow initialization
# Don't wait for katib or a few other things that take longer to initialize
export KUBEFLOW_DEPLOYMENTS="profiles-deployment centraldashboard ml-pipeline minio mysql metadata-db"
./scripts/k8s_deploy_kubeflow.sh -w
sleep 60 # Do this to allow appropriate "kubeflow initialization" time

kubectl get pods -n kubeflow # Do this for debug purposes

# Run the Kubeflow pipeline test, this will build a pipeline that launches an NGC container
timeout 600 python3 .jenkins-scripts/test-kubeflow-pipeline.py

#!/bin/bash
set -e

export AWS_DEFAULT_REGION="ap-south-1"

SECRET_ID="sepm-back-secrets"

echo "Pulling secrets from AWS and creating Kubernetes secret..."

SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_ID --query SecretString --output text)


echo "$SECRET_JSON" | python3 -c "
import json, sys
d = json.load(sys.stdin)
# Process and print secret format
for k, v in d.items():
    print(f'{k.strip()}={v.strip()}')
" | kubectl create secret generic $SECRET_ID --from-env-file=/dev/stdin --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying backend..."
kubectl apply -f back-deploy.yaml
kubectl apply -f service-back.yaml

echo "Deploying frontend..."
kubectl apply -f front-deploy.yaml
kubectl apply -f service-front.yaml

echo "Done! Checking status..."
kubectl get all

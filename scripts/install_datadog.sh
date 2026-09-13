#!/usr/bin/env bash
set -euo pipefail
: "${DD_API_KEY:?Defina DD_API_KEY}"
kubectl create namespace datadog --dry-run=client -o yaml | kubectl apply -f -
kubectl -n datadog create secret generic datadog-secret --from-literal=api-key="$DD_API_KEY" --dry-run=client -o yaml | kubectl apply -f -
helm repo add datadog https://helm.datadoghq.com
helm repo update
helm upgrade --install datadog datadog/datadog -n datadog -f k8s/datadog-values.yaml

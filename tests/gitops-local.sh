#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
export KUBECONFIG="${KUBECONFIG:-${root}/.kube/config}"
flux_version="${FLUX_VERSION:-2.9.5}"

kubectl apply -f "https://github.com/fluxcd/flux2/releases/download/v${flux_version}/install.yaml"
kubectl -n flux-system wait --for=condition=Available deploy --all --timeout=5m

kubectl apply -k "${root}/gitops/infrastructure/controllers"
kubectl wait --for=condition=Ready helmrelease --all --all-namespaces --timeout=20m

kubectl apply -k "${root}/gitops/infrastructure/configs"
kubectl -n gateway wait --for=condition=Programmed gateway/lab --timeout=5m

kubectl apply -k "${root}/gitops/apps"
kubectl -n demo rollout status deploy/podinfo --timeout=5m

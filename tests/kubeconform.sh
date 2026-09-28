#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

conform() {
  docker run --rm -i ghcr.io/yannh/kubeconform:v0.7.0 -strict -summary -skip Cluster \
    -schema-location default \
    -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' -
}

for dir in gitops/infrastructure/controllers gitops/infrastructure/configs gitops/apps; do
  echo "== ${dir}"
  kubectl kustomize "${root}/${dir}" | conform
done

echo "== gitops/clusters/lab"
conform < "${root}/gitops/clusters/lab/infrastructure.yaml"

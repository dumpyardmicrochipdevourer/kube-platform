#!/usr/bin/env bash
set -Eeuo pipefail

node="${E2E_NODE:-k8s-cp1}"
kc="sudo kubectl --kubeconfig /etc/kubernetes/admin.conf"

run() { limactl shell "${node}" -- bash -c "$*"; }

run "${kc} wait --for=condition=Ready node --all --timeout=120s"

nodeport="$(run "${kc} -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=lab -o jsonpath='{.items[0].spec.ports[0].nodePort}'")"

body="$(run "curl -fsS --retry 10 --retry-delay 3 --retry-connrefused -H 'Host: podinfo.lab.local' http://127.0.0.1:${nodeport}/")"
echo "${body}" | grep -q '"hostname"'
echo "e2e ok: podinfo answers through the Gateway on nodePort ${nodeport}"

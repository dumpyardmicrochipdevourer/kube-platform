#!/usr/bin/env bash
set -Eeuo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cp_count="${CP_COUNT:-1}"
worker_count="${WORKER_COUNT:-1}"
cpus="${NODE_CPUS:-2}"
memory="${NODE_MEMORY:-3}"
disk="${NODE_DISK:-20}"

names=()
for i in $(seq 1 "${cp_count}"); do names+=("k8s-cp${i}"); done
for i in $(seq 1 "${worker_count}"); do names+=("k8s-w${i}"); done

start() {
  local name="$1"
  if limactl list --quiet | grep -qx "${name}"; then
    limactl start "${name}" >/dev/null 2>&1 || true
    echo "${name}: exists"
    return
  fi
  limactl start --name="${name}" --tty=false --vm-type=vz --mount-none --containerd=none \
    --cpus="${cpus}" --memory="${memory}" --disk="${disk}" "${here}/node.yaml"
  echo "${name}: started"
}

pids=()
for name in "${names[@]}"; do
  start "${name}" &
  pids+=($!)
done

rc=0
for pid in "${pids[@]}"; do wait "${pid}" || rc=1; done
exit "${rc}"

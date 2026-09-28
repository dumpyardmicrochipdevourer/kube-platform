#!/usr/bin/env bash
set -Eeuo pipefail

mapfile -t names < <(limactl list --quiet | grep -E '^k8s-(cp|w)[0-9]+$' || true)

if [ "${#names[@]}" -eq 0 ]; then
  echo "no k8s-* instances"
  exit 0
fi

for name in "${names[@]}"; do
  echo "deleting ${name}"
  limactl delete --force "${name}"
done

#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys

LIMA_HOME = os.environ.get("LIMA_HOME", os.path.expanduser("~/.lima"))
CP = re.compile(r"^k8s-cp\d+$")
WORKER = re.compile(r"^k8s-w\d+$")


def instances():
    out = subprocess.run(["limactl", "list", "--json"], capture_output=True, text=True, check=True).stdout
    return [json.loads(line) for line in out.splitlines() if line.strip()]


def build():
    inventory = {
        "_meta": {"hostvars": {}},
        "control_plane": {"hosts": []},
        "workers": {"hosts": []},
        "k8s_cluster": {"children": ["control_plane", "workers"]},
    }
    for inst in sorted(instances(), key=lambda i: i["name"]):
        name = inst["name"]
        if CP.match(name):
            group = "control_plane"
        elif WORKER.match(name):
            group = "workers"
        else:
            continue
        inventory[group]["hosts"].append(name)
        inventory["_meta"]["hostvars"][name] = {
            "ansible_host": f"lima-{name}",
            "ansible_ssh_common_args": f"-F {LIMA_HOME}/{name}/ssh.config",
            "ansible_python_interpreter": "/usr/bin/python3",
        }
    return inventory


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--host":
        print(json.dumps({}))
    else:
        print(json.dumps(build(), indent=2))

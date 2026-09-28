SHELL := /bin/bash
INVENTORY ?= inventory/lima.py
ANSIBLE := cd bootstrap && ansible-playbook -i $(INVENTORY)

GITOPS_REPO_URL ?=

.PHONY: up vms install gitops gitops-local e2e upgrade backup restore reset destroy lint kubeconfig

up: vms install gitops-local

vms:
	infra/lima/up.sh

install:
	$(ANSIBLE) playbooks/install.yml

gitops-local:
	tests/gitops-local.sh

gitops:
	KUBECONFIG=$(CURDIR)/.kube/config flux bootstrap git --url=$(GITOPS_REPO_URL) --branch=main --path=gitops/clusters/lab

e2e:
	tests/e2e.sh

upgrade:
	$(ANSIBLE) playbooks/upgrade.yml -e kube_version=$(VERSION) -e kube_minor=$(MINOR)

backup:
	$(ANSIBLE) playbooks/backup.yml

restore:
	$(ANSIBLE) playbooks/restore.yml -e snapshot=$(SNAPSHOT)

reset:
	$(ANSIBLE) playbooks/reset.yml

destroy:
	infra/lima/down.sh

kubeconfig:
	@echo KUBECONFIG=$(CURDIR)/.kube/config

lint:
	yamllint .
	cd bootstrap && ansible-lint
	tests/kubeconform.sh

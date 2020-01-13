#!/bin/bash
set -e

cd /tmp/dotfiles
ansible-playbook playbook.yaml

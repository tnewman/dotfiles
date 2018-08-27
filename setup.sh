#!/bin/bash
sudo apt update
sudo apt install -y ansible git
ansible-playbook dotfiles.yml


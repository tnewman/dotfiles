#!/bin/bash
set -e

app_directory=~/.dotfiles
bin_directory=$app_directory/bin
node_version=10
script_directory=$(pwd)

packages=(
    base-devel
    bridge-utils
    code
    dnsmasq
    docker
    ebtables
    git
    kubectl
    libvirt
    minikube
    openbsd-netcat
    qemu
    vde2
    vim
    virt-manager
)

bins=(
    https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
)

scripts=(
    
)

vs_code_extensions=(
    dbaeumer.vscode-eslint
    EditorConfig.EditorConfig
)

function update() {
    echo "Upgrading Arch"

    echo "====> Upgrading Arch"
    sudo pacman -Syu --noconfirm
}

function install_packages() {
    echo "Installing Packages"
    sudo pacman -S --needed --noconfirm ${packages[@]}
}

function initialize_app_directory() {
    echo "Initializing App Directory"

    echo "====> Clearing $app_directory"
    rm -rf $app_directory

    echo "====> Creating $app_directory"
    mkdir -p $app_directory

    echo "====> Creating $bin_directory"
    mkdir -p $bin_directory
}

function install_bins() {
    echo "Installing Bins"

    echo "====> Moving to $bin_directory"
    cd $bin_directory

    for bin_url in ${bins[@]}
    do
        bin=${bin_url##*/}
        echo "====> Downloading $bin"
        curl -o $bin $bin_url
        echo "====> Making $bin Executable"
        chmod +x $bin
    done
}

function install_nvm() {
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
}

function install_vs_code_extensions() {
    echo "Installing VS Code Extensions"

    for vs_code_extension in ${vs_code_extensions[@]}
    do
        echo "====> Installing $vs_code_extension"
        code --install-extension $vs_code_extension
    done
}

function install_configuration() {
    echo "Installing Configuration"

    echo "====> Moving to $script_directory"
    cd $script_directory

    echo "====> Copying .bashrc"
    cp .bashrc $app_directory
    bashrc_path="source $app_directory/.bashrc"
    grep -qxF "$bashrc_path" ~/.bashrc || echo "$bashrc_path" >> ~/.bashrc
    source ~/.bashrc

    echo "====> Copying .vimrc"
    cp .vimrc $app_directory
    ln -f -s $app_directory/.vimrc ~/.vimrc

    echo "====> Add User ($USER) to Docker Group"
    sudo usermod -aG docker $USER

    echo "====> Add User ($USER) to libvirt Group"
    sudo usermod -aG libvirt $USER

    echo "====> Start and Enable Docker"
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "====> Start and Enable libvirt"
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd

    echo "====> Enable Minikube KVM Driver"
    minikube config set vm-driver kvm2
}

update
install_packages
initialize_app_directory
install_bins
install_nvm
install_vs_code_extensions
install_configuration

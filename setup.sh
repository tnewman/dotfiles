#!/bin/bash
set -e

app_directory=~/.dotfiles
bin_directory=$app_directory/bin
distro=$(lsb_release -s -c)
node_version=10
script_directory=$(pwd)

apt_keys=(
    "https://deb.nodesource.com/gpgkey/nodesource.gpg.key"
    "https://download.docker.com/linux/ubuntu/gpg"
    "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
)

repos=(
    "deb https://apt.kubernetes.io/ kubernetes-xenial main"
    "deb https://deb.nodesource.com/node_${node_version}.x $distro main"
    "deb-src https://deb.nodesource.com/node_${node_version}.x $distro main"
    "deb https://download.docker.com/linux/ubuntu $distro stable"
)

packages=(
    bridge-utils
    build-essential
    containerd.io
    curl
    default-jdk
    docker-ce
    docker-ce-cli
    gconf2
    git
    jq
    kubectl
    libvirt-clients
    libvirt-daemon-system
    nodejs
    python3-pip
    python3-venv
    qemu-kvm
    ubuntu-restricted-extras
    vim
    virt-manager
)

bins=(
    https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
    https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64)

function install_apt_keys() {
    echo "Installing APT Keys"

    for apt_key in ${apt_keys[@]}
    do
        echo "====> Installing $apt_key"
        wget -qO- $apt_key | sudo apt-key add -
    done
}

function install_repos() {
    echo "Installing APT Repos"

    sudo rm -f /etc/apt/sources.list.d/dotfiles.list

    for repo in "${repos[@]}"
    do
        echo "====> Installing $repo"
        echo "$repo" | sudo tee -a /etc/apt/sources.list.d/dotfiles.list > /dev/null
    done
}

function update() {
    echo "Updating Ubuntu"

    echo "====> Updating Package Cache"
    sudo apt-get update

    echo "====> Updating Packages"
    sudo apt-get dist-upgrade -y

    echo "====> Removing Obsolete Packages"
    sudo apt-get autoremove -y
}

function install_packages() {
    echo "Installing Packages"
    sudo apt-get install -qq -y ${packages[@]}

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
        wget --quiet $bin_url
        echo "====> Making $bin Executable"
        chmod +x $bin
    done

    echo "====> Renaming minikube"
    mv $bin_directory/minikube-linux-amd64 minikube
}

function install_jetbrains_toolbox() {
    echo "Installing Jetbrains Toolbox"
    if [ -d ~/.local/share/JetBrains/Toolbox ]; then
        echo "====> Jetbrains Toolbox Already Exists (Skipping Installation)"
    else
        echo "====> Installing Jetbrains Toolbox"
        toolbox_url=$(wget -qO- "https://data.services.jetbrains.com//products/releases?code=TBA&latest=true&type=release" | jq -r '.TBA[0].downloads.linux.link')
        wget -qO- $toolbox_url | tar -zxO --wildcards --no-anchored 'jetbrains-toolbox' > /tmp/jetbrains-toolbox
        chmod +x /tmp/jetbrains-toolbox
        /tmp/jetbrains-toolbox &
    fi
}

function install_configuration() {
    echo "Installing Configuration"
    
    echo "====> Installing .vimrc"
    cp $script_directory/.vimrc $app_directory
    ln -f -s $app_directory/.vimrc ~/.vimrc

    echo "====> Installing .bashrc"
    cp $script_directory/.bashrc $app_directory
    rm ~/.bashrc
    ln -f -s $app_directory/.bashrc ~/.bashrc
    source ~/.bashrc

    echo "====> Setting Terminal Transparency"
    gconftool-2 --set /apps/gnome-terminal/profiles/Default/background_darkness --type=float 0.50

    echo "====> Add User to Docker Group"
    sudo usermod -aG docker $USER
    
    echo "====> Add User to libvirt Group"
    sudo usermod -aG libvirt $USER
    
    echo "====> Enable Minikube KVM Driver"
    minikube config set vm-driver kvm2
}

install_apt_keys
install_repos
update
install_packages
initialize_app_directory
install_bins
install_jetbrains_toolbox
install_configuration


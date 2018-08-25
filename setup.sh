#!/bin/bash
set -e

ppas=(
    ppa:cwchien/gradle
    ppa:linuxuprising/java
)

packages=(
    build-essential
    dconf-cli
    curl
    docker-ce
    git
    gradle
    oracle-java10-installer
    oracle-java10-set-default
    python3-pip
    ubuntu-restricted-extras
    vim
    virtualbox
    wget
)
   

tarballs=(
    https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.11.4231.tar.gz
)

zips=(
    https://dl.google.com/dl/android/studio/ide-zips/3.1.4.0/android-studio-ide-173.4907809-linux.zip
)

bins=(
    https://github.com/kubernetes/minikube/releases/download/v0.28.2/minikube-linux-amd64
    https://storage.googleapis.com/kubernetes-release/release/v1.11.2/bin/linux/amd64/kubectl
)

git_repos=(
    https://github.com/Anthony25/gnome-terminal-colors-solarized.git
    https://github.com/altercation/vim-colors-solarized.git
)

python3_packages=(
    virtualenv
)

app_directory=~/.dotfiles
bin_directory=$app_directory/bin
script_directory=$(pwd)

function install_ppas() {
    echo "Installing PPAs"
    
    for ppa in ${ppas[@]}
    do
        echo "====> Installing $ppa"
        sudo add-apt-repository -y $ppa
    done
}

function install_docker_repo() {
    echo "Installing Docker Repository"

    echo "====> Installing Prerequisites"
    sudo apt-get install -qq -y apt-transport-https ca-certificates curl \
        software-properties-common

    echo "====> Adding Docker GPG Key"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "====> Adding Docker Repository"
    sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
           $(lsb_release -cs) \
           edge"
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
    
    for package in ${packages[@]}
    do
        echo "====> Installing $package"
        sudo apt-get install -qq -y $package
    done
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

function install_tarballs() {
    echo "Installing Tarballs"

    echo "====> Moving to $app_directory"
    cd $app_directory

    for tarball_url in ${tarballs[@]}
    do
        tarball=${tarball_url##*/}
        echo "====> Downloading $tarball_url"
        wget --quiet $tarball_url
        
        echo "====> Extracting $tarball"
        tar -xf $tarball
        
        echo "====> Removing $tarball"
        rm $tarball
    done
}

function install_zips() {
    echo "Installing Zips"
    
    echo "====> Moving to $app_directory"
    cd $app_directory

    for zip_url in ${zips[@]}
    do
        zip=${zip_url##*/}
	    echo "====> Downloading $zip_url"
	    wget --quiet $zip_url

	    echo "====> Extracting $zip"
	    unzip -qq $zip

	    echo "====> Removing $zip"
	    rm $zip
    done
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

function install_git_repos() {
    echo "Installing Git Repos"
    
    echo "====> Moving to $app_directory"
    cd $app_directory
    
    for repo_url in ${git_repos[@]}
    do
        echo "====> Cloning $repo_url"
	git clone -q $repo_url
    done
}

function install_python3_packages() {
    echo "Installing Python 3 Packages"
    
    for package in ${python3_packages[@]}
    do
        echo "====> Installing $package"
        pip3 install -q --user $package
    done
}

function install_terminal_profile() {
    echo "====> Create SolarizedDark Terminal Profile"
    dconf write /org/gnome/terminal/legacy/profiles:/:be8a3d5c-f849-4996-817d-bb694f75fca5/visible-name "'Solarized Dark'"
    dconf write /org/gnome/terminal/legacy/profiles:/list "['be8a3d5c-f849-4996-817d-bb694f75fca5']"

    echo "====> Set Default Terminal Profile to Solarized Dark"
    dconf write /org/gnome/terminal/legacy/profiles:/default "'be8a3d5c-f849-4996-817d-bb694f75fca5'"
    
    echo "====> Installing Solarized Terminal Colors"
    $app_directory/gnome-terminal-colors-solarized/install.sh \
        --profile "Solarized Dark" --scheme dark \
        --skip-dircolors

    echo "====> Setting Terminal Transparency"
    dconf write /org/gnome/terminal/legacy/profiles:/:be8a3d5c-f849-4996-817d-bb694f75fca5/use-theme-transparency false
    dconf write /org/gnome/terminal/legacy/profiles:/:be8a3d5c-f849-4996-817d-bb694f75fca5/use-transparent-background true
    dconf write /org/gnome/terminal/legacy/profiles:/:be8a3d5c-f849-4996-817d-bb694f75fca5/background-transparency-percent 10
}

function install_vim_profile() {
    echo "====> Installing Pathogen for Vim"
    mkdir -p ~/.vim/autoload
    wget --quiet -O $app_directory/pathogen.vim https://tpo.pe/pathogen.vim
    ln -f -s $app_directory/pathogen.vim ~/.vim/autoload/pathogen.vim
    
    echo "====> Installing .vimrc"
    cp $script_directory/.vimrc $app_directory
    ln -f -s $app_directory/.vimrc ~/.vimrc
    
    echo "====> Installing Vim Solarized Colors"
    mkdir -p ~/.vim/bundle
    ln -f -s $app_directory/vim-colors-solarized ~/.vim/bundle/vim-colors-solarized
}

function install_configuration() {
    echo "Installing Configuration"
    install_terminal_profile
    install_vim_profile
    
    echo "====> Installing .bashrc"
    cp $script_directory/.bashrc $app_directory
    rm ~/.bashrc
    ln -f -s $app_directory/.bashrc ~/.bashrc
    source ~/.bashrc

    echo "====> Add User to Docker Group"
    sudo usermod -aG docker $USER
}

install_ppas
install_docker_repo
update
install_packages
initialize_app_directory
install_tarballs
install_zips
install_bins
install_git_repos
install_python3_packages
install_configuration


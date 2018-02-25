#!/bin/bash
set -e

ppas=(
    ppa:cwchien/gradle
    ppa:webupd8team/java
)

packages=(
    build-essential
    dconf-cli
    git
    gradle
    mongodb-org
    nodejs
    oracle-java9-installer
    oracle-java9-set-default
    python3-pip
    postgresql
    postgresql-contrib
    vim
    wget
)
   

tarballs=(
    https://download.jetbrains.com/idea/ideaIU-2017.3.4-no-jdk.tar.gz
    https://download.jetbrains.com/python/pycharm-professional-2017.3.3.tar.gz
    https://download.jetbrains.com/webstorm/WebStorm-2017.3.4.tar.gz
)

git_repos=(
    https://github.com/Anthony25/gnome-terminal-colors-solarized.git
    https://github.com/altercation/vim-colors-solarized.git
)

python3_packages=(
    virtualenv
)

node_packages=(
    @angular/cli
)

app_directory=~/.dotfiles
script_directory=$(pwd)

function update() {
    echo "Updating Ubuntu"
    
    echo "====> Updating Package Cache"
    sudo apt-get update
    
    echo "====> Updating Packages"
    sudo apt-get dist-upgrade -y
    
    echo "====> Removing Obsolete Packages"
    sudo apt-get autoremove -y
}

function install_ppas() {
    echo "Installing PPAs"
    
    for ppa in ${ppas[@]}
    do
        echo "====> Installing $ppa"
        sudo add-apt-repository -y $ppa
    done
}

function install_repos() {
    echo "Installing Repos"
    
    # Bootstrap wget
    echo "====> Installing wget (bootstrap)"
    sudo apt-get install -qq -y wget

    echo "====> Installing NodeSource Repo"
    wget -qO- https://deb.nodesource.com/setup_9.x | sudo bash -
    
    echo "====> Installing MongoDB Repo"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
    sudo rm -f /etc/apt/sources.list.d/mongodb-org-3.6.list
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee -a /etc/apt/sources.list.d/mongodb-org-3.6.list >/dev/null
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

function install_node_packages() {
    echo "Installing Node Packages"

    for package in ${node_packages[0]}
    do
        echo "====> Installing $package"
        sudo npm install -g $package --unsafe
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
    
    echo "====> Installing BASH Profile"
    cp $script_directory/.bash_profile $app_directory
    ln -f -s $app_directory/.bash_profile ~/.bash_profile
    source ~/.bash_profile
}

install_ppas
install_repos
update
install_packages
initialize_app_directory
install_tarballs
install_git_repos
install_python3_packages
install_node_packages
install_configuration

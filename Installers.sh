#!/usr/bin/env bash

installFlatpak(){ # instala o gerenciador de pacotes flatpak e adiciona o repositorio flathub
    sudo apt install flatpak -y
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    read -p "caso deseje que sua loja de aplicativos tenha suporte para flatpak, digite o nome do seu ambiente ou deixei vazio (gnome|kde)" op
    [[ ${op,} = "gnome" ]] && sudo apt install gnome-software-plugin-flatpak
    [[ ${op,} = "kde" ]] && apt install plasma-discover-backend-flatpak
    echo "Para concluir a configuração, reinicie o sistema"
    read -p "Tecle 'enter' para continuar... "
}

installDocker(){ # Instala o docker-cli e docker-desktop de acordo com a doc do docker
    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add the repository to Apt sources:
    echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  read -p "Deseja instalar dockerhub ? [S/n]" op
  [[ ${op,} = "n" ]] && return
  wget -O dockerhub.deb -q --show-progress "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.24.0-amd64.deb? \
                                            utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64" \
                                           && wait && apt install ./dockerhub.deb && rm -rf dockerhub.deb
  read -p "Tecle 'enter' para continuar... "
}

installSteam(){
    if ! grep -qE "^\s*deb\s.*\s(non-free|contrib)" /etc/apt/sources.list; then
	read -p "não foi encontrado non-free contrib (necessario para instalar steam). deseja adiciona  ? [S/n]" op
	[[ ${op,} = "n" ]] && return
	sudo sed -i '/^deb/s/$/ non-free contrib/' /etc/apt/sources.list
    fi
    echo -e "\nInstalando Steam...\n"
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install steam gamemode
    read -p "Tecle 'enter' para continuar... "
}

installAppFlatpak(){
    flatpak install flathub md.obsidian.Obsidian -y
    flatpak install io.gitlab.idevecore.Pomodoro -y
    flatpak install org.prismlauncher.PrismLauncher -y
    read -p "Tecle 'enter' para continuar... "
}

installOhMyZsh(){
  sudo apt install zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

installChrome(){
 wget -O chrome.deb -q --show-progress "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
                                           && wait && apt install ./chrome.deb && rm -rf chrome.deb
}

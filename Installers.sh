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
  enableFlagsApt
  echo -e "\nInstalando Steam...\n"
  sudo apt update
  sudo apt install steam-installer gamemode mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 -y
  read -p "Tecle 'enter' para continuar... "
}
enableFlagsApt(){
  if ! grep -qE "^\s*deb\s.*\s(non-free)" /etc/apt/sources.list; then
	  sudo sed -i '/^deb/s/$/ non-free/' /etc/apt/sources.list
  fi

  if ! grep -qE "^\s*deb\s.*\s(contrib)" /etc/apt/sources.list; then
	  sudo sed -i '/^deb/s/$/ contrib/' /etc/apt/sources.list
  fi

  if ! grep -qE "^\s*deb\s.*\s(non-free-firmware)" /etc/apt/sources.list; then
	  sudo sed -i '/^deb/s/$/ non-free-firmware/' /etc/apt/sources.list
  fi

  sudo dpkg --add-architecture i386
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
                                           && wait && sudo apt install ./chrome.deb && rm -rf chrome.deb
}

installIntellij(){
  curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null
  sudo apt update
  sudo apt install intellij-idea-ultimate
}

installXmonad(){
  sudo apt install libx11-dev libxft-dev libxinerama-dev libxrandr-dev libxss-dev haskell-stack xmobar trayer git -y
  stack upgrade
  mkdir ~/.config/xmonad
  cd ~/.config/xmonad/
  git clone https://github.com/xmonad/xmonad
  git clone https://github.com/xmonad/xmonad-contrib
  stack init && stack install
}

installVirtualMachine(){
  sudo apt install qemu-kvm qemu-system qemu-utils python3 python3-pip libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y
  sudo virsh net-start default
  sudo virsh net-autostart default
  sudo virsh net-list --all
  sudo usermod -aG libvirt $USER
  sudo usermod -aG libvirt-qemu $USER
  sudo usermod -aG kvm $USER
  sudo usermod -aG input $USER
  sudo usermod -aG disk $USER
}

installDwm(){
  sudo apt install make gcc libx11-dev libxft-dev libxinerama-dev suckless-tools git -y
  git clone https://github.com/eduardoSilvaDiniz/suckless.git ~/.config/
  dirs=$(ls ~/.config/suckless/)
  # shellcheck disable=SC2068
  for a in ${dirs[@]}; do
    cd ~/.config/suckless/$a
    sudo make clean install
  done
}
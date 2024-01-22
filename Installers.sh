installFlatpak() # instala o gerenciador de pacotes flatpak e adiciona o repositorio flathub
{ # BUG, mesmo sendo usuario, o ultimo comando não é executado
	sudo apt install flatpak -y
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

installBrave() # Adiciona PPA oficial do brave e instala o brave
{
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/  \
                                                        stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update && sudo apt install brave-browser -y
}

installDocker() # Instala o docker-cli e docker-desktop de acordo com a doc do docker
{
  sudo apt install ca-certificates curl gnupg -y
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg]
                                          https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                                          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  # install dockerhub
  # adiciona pergunta para saber se o usuario quer instalar dockerhub
  #BUG, esta instalando discord.deb
  wget -O dockerhub.deb -q --show-progress "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.24.0-amd64.deb? \
                                            utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64" \
                                            && wait && apt install ./discord.deb && rm -rf dockerhub.deb
}

installSteam() # BUG, script esta baguçado
{
  echo -e "Esta opção ativa a arquiterura i386 e instala o cliente Steam.\n"
    continuar
  if (($?)); then
	  echo -e "\nInstalando Steam...\n"
	  sudo dpkg --add-architecture i386
	  sudo apt update
	  sudo apt install steam gamemode
	  read -p "Tecle 'enter' para continuar... "
  fi
}

installAppFlatpak()
{
  flatpak install flathub md.obsidian.Obsidian -y
  flatpak install com.jetbrains.IntelliJ-IDEA-Ultimate com.jetbrains.CLion -y
  flatpak install io.gitlab.idevecore.Pomodoro -y
}

installOhMyZsh()
{
  sudo apt install zsh
  if [ $USER -ne 0 ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "Você é root, apenas nivel usuario [ERROR]"
  fi
}

installPipewire()
{
  sudo apt install wireplumber pipewire pipewire-pulse pipewire-alsa libspa-0.2-bluetooth \
  pulseaudio-utils pulsemixer pavucontrol alsa-utils
  systemctl --user enable --now pipewire wireplumber
}
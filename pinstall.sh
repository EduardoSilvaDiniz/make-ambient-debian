#!/usr/bin/env bash
source Installers.sh ## chamado script com todas as funções de instalação
#TODO adiciona alguma forma de adiciona ssh do github, copiar id-25519 do keepass para $HOME/.ssh/
#TODO organizar o codigo

(($UID==0)) && { echo 'não é permitido executar esse script como root. [ERROR]'; exit 1 ;}

release="0.3"
pkgsPath="$(pwd)/lists"
versionDebian="12 (bookworm)"
line=""
instalando=
"
  $line
  Instalando...
  $line
"

mainTitle="$line
INSTALAR E CONFIGURAR - SISTEMA: DEBIAN ${versionDebian} RELEASE: ${release}
$line"
mainMenu="$mainTitle
  0. Conecta a Internet (usb ou wifi)
  1. Adiciona Usuario ao Sudo
  2. Instalar drivers Nvidia
  3. Softwares de Uso diario
  4. Softwares de enteterimento
  5. Softwares de desenvolvimento (C/C++, Java, haskell, golang)
  6. instalar Window Manager (dwm, xmonad)
  7. instalar complementos para window manager (dwm/xmonad)
  8. limpa ambiente (remove apps pre-instalado, autoremove)
  9. configurar Sistema
  10. Virtualização

$line
   Q. Sair
$line
Escolha uma opção: "

wifiMenu="1. Wifi (Será usando keepassxc-cli para pegar a senha no diretorio wifi/NomeDoWifi)
2. Usb (Tethring USB android)
Escolha uma opção: "


readPkgs(){
    pkgs_list=$(grep -vE "^\s*#" $1 | sed '/^\s*$/d')
    pkgs_apti=$(tr "\n" " " <<< $pkgs_list)
}

packageManager(){
    readPkgs "$pkgsPath/$1"
    clear
    echo "$mainTitle"
    echo -e "Os pacotes da lista '$1' serão $2:\n"
    echo -e "$pkgs_list\n"
    read -p "Deseja continuar (S/n)? " op
    [[ ${op,} = "n" ]] && return
    if (($?)); then
        echo "$instalando"
        sudo apt $2 -y $pkgs_apti
        if (($?)); then
            echo -e "\n$line\nA instalação falhou!\nVerifique a lista de pacotes '$1' e tente novamente.\n$line\n"
        else
            echo -e "\n$line\nSucesso!\n$line\n"
        fi
        read -p "Tecle 'enter' para continuar... "
    fi
}

menuNetwork(){
  while true; do
      clear
      echo -e "$wifiMenu\c"
      read option
      case $option in
	  1) connectWifi && break ;;
	  2) connectUSB && break ;;
	  *) echo "opção invalida [ERROR]" ;;
      esac
  done
}

connectWifi(){
  sudo apt install keepassxc -y
  clear
  while $status; do
    read -p "Digite o endereço do seu banco de senhas (Exemplo /home/user/db.kdbx): " database
    read -s -p "Digite a senha do seu banco de senhas: " passDatabase
    if echo "$passDatabase" | keepassxc-cli ls "$database" &> /dev/null; then
      echo -e "\nAcesso ao banco de senhas bem-sucedido" && status=false
    else
      echo -e "\nFalha no acesso ao banco de senhas. Verifique a senha e o caminho do banco de senhas. [ERROR]"
    fi
  done

  while true; do
    nmcli device wifi list
    read -p "Digite o nome (SSID) do Wi-Fi (ou ENTER para recarregar): " wifiName

    if [ -z "$wifiName" ]; then
      continue
    else
      password=$(echo "$passDatabase" | keepassxc-cli show -sa password "${database}" wifi/"${wifiName}")
      if [ -z "$password" ]; then
        echo "Nome do wifi invalido [ERROR]"
      else
        nmcli device wifi connect "${wifiName}" password "${password}" && echo "conexão bem sucedido" && return
      fi
    fi
  done
}

connectUSB(){
  ip a > ip-a && awk -F ': ' '{ print $2 }' ip-a > ip-a && network=$(awk '/enx/ { print }' a-mod) && \
  ip link set dev ${network} up && dhclient
}

AddUserSudo(){
    USUARIO=$USER
    echo "Digite a senha de ROOT"
    su -c "apt install sudo; adduser $USUARIO sudo"
}

SoftwaresDaily(){
    packageManager daily install
    installFlatpak
    installAppFlatpak
    installOhMyZsh
    installChrome
}
SoftwaresDev(){
  packageManager dev install
  installIntellij
}
SoftwaresEntertainment(){
  packageManager entertainment install
  installSteam
}
installWM(){
  clear
  while true ; do
    read -p "Qual window manager quer instalar [dwm/xmonad] ? " option
    case $option in
      dwm) installDwm && break ;;
      xmonad) installXmonad && break ;;
      *) echo 'opção invalida' ;;
    esac
  done
}
#TODO
# configurar o crontab
# alerta de que esta proximo das 10 PM
# atualização do sistema
# atualizar repos (dotfiles, xmonad, save do minecraft)
# desligar depois das 10 PM
# compactar e criptografar a pasta sync e enviar para onedrive/adventista

#TODO adiciona verificação se o diretorio ou link simbolico já exite e perguntar o que deseja fazer [apagar/ignorar]
configAmbient(){
  ## dotfiles
  echo -e "ATENÇÃO será usando git clone via SSH, se você ainda não configurou seu SSH, cancele esse script com (Ctrl+c)\n"
  read -p "Tecle 'enter' para continuar... "
  mkdir ~/.local/repos
  read -p "Qual é o nome do seu usuario no github? " name
  git clone git@github.com:$name/dotfiles.git ~/.local/repos/dotfiles/

  #files=$(echo * ~/.local/repos/dotfiles/home | grep -vE '^\.$|^\.\.$')
  files=()
  for file in ~/.local/repos/dotfiles/home/*; do
    files+=("$(basename "$file")")
  done

  #dirsConfig=$(ls ~/.local/repos/dotfiles/.config | grep -vE '^ALERT$|^systemd$')
  filesConfig=()
  for file in ~/.local/repos/dotfiles/.config/*; do
    if [ "$file" != "ALERT" ] && [ "$file" != "systemd" ]; then
      filesConfig+=("$(basename "$file")")
    fi
  done

  for a in "${files[@]}"; do
  	ln -s ~/.local/repos/dotfiles/home/$a ~/$a
  done

  for a in "${filesConfig[@]}"; do
  	ln -s ~/.local/repos/dotfiles/.config/$a ~/.config/$a
  done

  mkdir -p ~/.config/systemd/user
  ln -s ~/.local/repos/dotfiles/.config/systemd/user/rclone-adventista.service ~/.config/systemd/user
  ln -s ~/.local/repos/dotfiles/.config/systemd/user/rclone-personal.service ~/.config/systemd/user

  mkdir ~/.local/rclone
  mkdir -p ~/.local/rclone/adventista
  mkdir -p ~/.local/rclone/personal

  systemctl --user enable --now rclone-personal.service
  systemctl --user enable --now rclone-adventista.service

  ## Xmonad
  read -p "você quer trazer suas config do xmonad [s/n] ? " op
  if [ "$op" == "s" ]; then
    git clone git@github.com:$name/xmonad.git ~/.local/repos/xmonad/
    filesXmonad=$(ls ~/.local/repos/xmonad)
    for a in "${filesXmonad[@]}"; do
    	ln -s ~/.local/repos/xmonad/$a ~/.config/xmonad/
    done
  fi

  ## syncthing
  read -p "seu diretorio Sync está sicronizado [s/n] ? " op
  if [ $op == "s" ]; then
    ln -s ~/Sync/default/Músicas ~/
    sudo systemctl enable --now syncthing@edu.service
  fi

  ## rclone
  #TODO permitir adiciona mais de um nome (cloud1 cloud2 cloud3...)
  #TODO error, nome do node no keepass é diferente do nome do rclone
  cloudService="onedrive"
  while $status; do
    read -p "Digite o endereço do seu banco de senhas (Exemplo /home/user/db.kdbx): " database
    read -s -p "Digite a senha do seu banco de senhas: " passDatabase
    if echo "$passDatabase" | keepassxc-cli ls "$database" &> /dev/null; then
      echo -e "\nAcesso ao banco de senhas bem-sucedido" && status=false
    else
      echo -e "\nFalha no acesso ao banco de senhas. Verifique a senha e o caminho do banco de senhas. [ERROR]"
    fi
  done

  while true; do
    read -p "Digite o nome do profile rclone : " cloud

    if [ -z "$cloud" ]; then
      continue
    else
      token=$(echo "$passDatabase" | keepassxc-cli show -sa password "${database}" Self-hosted/"${cloud}")
      if [ -z "${token}" ]; then
        echo "Nome da cloud invalido [ERROR]"
      else
        mkdir ~/.config/rclone
        echo -e "["${cloud}"]\ntype = "${cloudService}"" >> ~/.config/rclone/rclone.conf
        echo "${token}" >> ~/.config/rclone/rclone.conf
        return
      fi
    fi
  done
}

while true; do
  clear
	echo -e "$mainMenu\c"
	read option
	case $option in
	    0) menuNetwork ;;
	    1) addUserSudo ;;
	    2) enableFlagsApt && packageManager driver-nvidia install ;;
	    3) SoftwaresDaily ;;
	    4) SoftwaresEntertainment ;;
	    5) SoftwaresDev ;;
	    6) installWM ;;
	    7) packageManager wm-tools install ;;
	    8) packageManager uninstall remove ;;
	    9) configAmbient ;;
	    10) installVirtualMachine ;;
	 [qQ]) echo -e "\nSaindo...\n"; exit 0;;
	esac
done

#!/usr/bin/env bash
source Installers.sh ## chamado script com todas as funções de instalação

#TODO NVIDIA-driver -> Adiciona suporte para nonfree...ETC e suporte arquitetura 32bits
#TODO STEAM -> abrir o install-steam para terminar de instalar a steam

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
   5. Ambiente de desenvolvimento (C/C++, Java, haskell, golang)
   6. Virtualização (não funciona)
   7. limpa ambiente (remove apps pre-instalado, autoremove)
   8. instalar Window Manager (dwm, xmonad)
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
  read -p "Qual window manager quer instalar ? [dwm/xmonad]" option
  while true ; do
    clear
    case $option in
      dwm) installDwm && break ;;
      xmonad) installXmonad && break ;;
      default) echo 'opção invalida' ;;
    esac
  done
  packageManager wm-tools install
}
#TODO Adiciona função para organizar meus arquivos do github DOTFILES EMACS-VANILLA DWM

while true; do
  clear
	echo -e "$mainMenu\c"
	read option
	case $option in
	    0) menuNetwork ;;
	    1) addUserSudo ;;
	    2) packageManager driver-nvidia install ;;
	    3) SoftwaresDaily ;;
	    4) SoftwaresDev ;;
	    5) SoftwaresEntertainment ;;
	    6) ;;
	    7) packageManager uninstall remove ;;
	    8) installWM ;;
	 [qQ]) echo -e "\nSaindo...\n"; exit 0;;
	esac
done

#!/bin/env bash
## Comando que você deseja executar
  ## atualiza o sistema e limpa pacotes desnecessarios
  update="sudo apt update && sudo apt upgrade && sudo apt autoremove && pacstall -U && pacstall -Up"

  ## sincroniza a minha pasta Sync com a nuvem
  rsync="rsync -avu --delete "/home/edu/Sync/" "/home/edu/Rclone/Adventista/Sync""

## Abrir o terminal e executar o comando
alacritty -- bash -c "$rsync" && alacritty -- bash -c "$update"

> [!WARNING]
> Este repositório está arquivado.
> 
> Não tenho mais interesse em mantê-lo, pois atualmente utilizo Fedora e NixOS como distros principais.
> 
> No futuro, posso criar uma nova versão desse projeto, focada nessas distribuições, utilizando ferramentas como Ansible e Go.

# make-ambient-debian

**make-ambient-debian** é um pequeno conjunto de scripts para automatizar a pós-instalação do Debian 12.

O objetivo foi agilizar a configuração de um ambiente de uso diário, incluindo ajustes no sistema, instalação de pacotes essenciais e personalizações voltadas para usuários que preferem window managers minimalistas como `dwm` e `xmonad`.

## Funcionalidades

- Adiciona automaticamente o usuário ao grupo `wheel` para acesso root (sudo)
- Configuração básica do `lightdm`
- Adição de diretórios personalizados ao `$PATH` do sistema
- Instalação de diversos softwares para:
  - Uso geral (navegador, utilitários, etc.)
  - Programação
  - Drivers da NVIDIA
  - Entretenimento
  - Conjunto de ferramentas úteis para uso com window managers baseados em X11
- Remoção de pacotes desnecessários instalados por padrão, como:
  - Jogos do GNOME
  - Firefox ESR
  - Outros utilitários considerados supérfluos para o ambiente proposto

## Interface TUI

O projeto inclui uma TUI simples (interface de terminal) para auxiliar em tarefas como:

- Conexão rápida com redes Wi-Fi
- Integração com senhas armazenadas no `keepassxc`
- Conexão via USB tethering com celular

> ⚠️ Nem todos os recursos do menu estão 100% funcionais ou finalizados.

---

Mesmo arquivado, este projeto pode servir de referência para quem deseja montar um ambiente Debian leve e customizado.  
Sinta-se à vontade para clonar ou forkar!

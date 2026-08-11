# TODO

> Dotfiles agora vivem **dentro do flake** em `home/configs/` e são
> aplicados pelo Home Manager (`home/default.nix`). Não há mais dependência
> de um repositório externo `~/dotfiles` para os programas gerenciados.
> O compositor continua `niri` + `waybar`.

- [ ] Confirmar boot mode real do `dell1564` (`ls /sys/firmware/efi`) — o
      comentário em `hosts/dell1564/default.nix` assume BIOS legado/GRUB
      mas ainda não foi confirmado no hardware.
- [ ] Confirmar o device do GRUB (`hosts/dell1564/default.nix`, atualmente
      hardcoded como `/dev/sda`) com `lsblk -f` no Dell antes do próximo
      rebuild do zero.
- [ ] WiFi Broadcom BCM4312 no `dell1564`: driver `b43` carrega mas
      `ucode15.fw` não é encontrado em runtime — investigar achatamento do
      path do firmware (ver histórico em memória/anotações do host).
- [x] Fase 2: migração para home-manager (tmpfiles → HM).
- [x] Fase 3: conteúdo dos dotfiles puxado para dentro do flake
      (`home/configs/`) + uso de módulos nativos (`programs.git`,
      `programs.helix`, `programs.bat`, `programs.btop`, `programs.tmux`,
      `programs.zsh`, `programs.direnv`) onde agregam valor.
- [ ] Avaliar se `.sops.yaml` deveria existir (hoje ausente) para
      centralizar os recipients age por host.
- [ ] Migrar mais opções para módulos nativos quando o ganho justificar
      (ex.: `programs.alacritty`, `programs.zellij` se/quando estáveis o
      suficiente, starship, atuin, etc.).
- [ ] Considerar mover pacotes puramente de usuário de
      `environment.systemPackages` para `home.packages`.

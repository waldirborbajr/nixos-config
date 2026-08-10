# TODO

> As duas linhas antigas deste arquivo (`stow -D waybar sway` / `stow -R
> i3status`) referenciavam `stow` e o stack `sway`/`i3status`, que não são
> mais usados neste repo: os dotfiles são linkados via
> `systemd.tmpfiles.rules` (ver `configuration.nix`), e o compositor atual
> é `niri` + `waybar` (não `sway`/`i3status`). Removidas por estarem
> obsoletas; itens reais em aberto ficam listados abaixo.

- [ ] Confirmar boot mode real do `dell1564` (`ls /sys/firmware/efi`) — o
      comentário em `hosts/dell1564/default.nix` assume BIOS legado/GRUB
      mas ainda não foi confirmado no hardware.
- [ ] Confirmar o device do GRUB (`hosts/dell1564/default.nix`, atualmente
      hardcoded como `/dev/sda`) com `lsblk -f` no Dell antes do próximo
      rebuild do zero.
- [ ] WiFi Broadcom BCM4312 no `dell1564`: driver `b43` carrega mas
      `ucode15.fw` não é encontrado em runtime — investigar achatamento do
      path do firmware (ver histórico em memória/anotações do host).
- [ ] Fase 2: migração para home-manager (dotfiles hoje symlinkados via
      `systemd.tmpfiles.rules` em `configuration.nix` + `hosts/*/default.nix`).
- [ ] Avaliar se `.sops.yaml` deveria existir (hoje ausente — ver nota no
      relatório de auditoria) para centralizar os recipients age por host.

# core.nix
# Hub central: módulos globais / system-level comuns a todos os hosts
# - Não coloque aqui coisas user-level (zsh, git, gh, etc.) → vão no home-manager
{ ... }:
{
  imports = [
    # Nixpkgs global + overlays/unfree
    ./modules/nixpkgs.nix

    # Base system (boot, locale, time, security básica, etc.)
    ./modules/base.nix

    # Networking (hosts, firewall, resolved, etc.)
    ./modules/networking.nix

    # Áudio (pipewire, etc.)
    ./modules/audio.nix

    # Fontes globais
    ./modules/fonts.nix

    # Features on-demand (devops tools, qemu)
    ./modules/features/devops.nix
    ./modules/features/qemu.nix

    # Usuário principal
    ./modules/users/borba.nix

    # Pacotes globais do sistema (se precisar, senão mover para HM)
    ./modules/system-packages.nix

    # Python/NodeJS global (se for usado por serviços ou múltiplos users)
    ./modules/python/default.nix
    ./modules/nodejs/default.nix

    # Flatpak + portal (precisa de system services)
    ./modules/flatpak/enable.nix
    ./modules/flatpak/packages.nix
    ./modules/xdg-portal.nix

    # SSH global (keys, config)
    ./modules/ssh.nix
  ];
}

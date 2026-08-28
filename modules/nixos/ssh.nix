# modules/nixos/ssh.nix
#
# OpenSSH server + client configuration. Private client identities are
# provisioned by sops-nix and never embedded in the Nix store.
{common, ...}: let
  inherit (common) username;
in {
  services.openssh = {
    enable = true;

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Keep the client identities separated by purpose:
  #   infra  -> SSH between managed environments
  #   github -> GitHub (existing key)
  #   gitlab -> GitLab (prepared for a dedicated key)
  #   forgejo -> Forgejo (prepared for a dedicated key)
  programs.ssh = {
    extraConfig = ''
      Host 192.168.* *.infra
        User ${username}
        IdentityFile /home/${username}/.ssh/id_ed25519_infra
        IdentitiesOnly yes

      Host github.com
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_github
        IdentitiesOnly yes

      Host gitlab.com
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_gitlab
        IdentitiesOnly yes

      Host forgejo.local
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_forgejo
        IdentitiesOnly yes

      Host gitea.com codeberg.org codefloe.com
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_github
        IdentitiesOnly yes
    '';
  };
}

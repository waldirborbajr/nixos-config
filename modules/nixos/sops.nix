# modules/nixos/sops.nix
#
# sops-nix: arquivo/segredos padrão + bootstrap zero-touch da chave de
# host SSH. Extraído 1:1 de configuration.nix (split cirúrgico, sem
# mudança de comportamento).
{
  hostname,
  common,
  ...
}: let
  inherit (common) username;
  sshKeysDir = "/home/${username}/.ssh";
in {
  # ==================== SOPS ====================
  sops = {
    defaultSopsFile = ../../hosts/${hostname}/secrets/${hostname}.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    validateSopsFiles = false;
  };

  sops.secrets."ssh_host_ed25519_key" = {
    path = "/etc/ssh/ssh_host_ed25519_key";
    owner = "root";
    mode = "0600";
  };

  sops.secrets."borba_ssh_infra_private_key" = {
    path = "${sshKeysDir}/id_ed25519_infra";
    owner = username;
    group = "users";
    mode = "0600";
  };

  sops.secrets."borba_ssh_infra_public_key" = {
    path = "${sshKeysDir}/id_ed25519_infra.pub";
    owner = username;
    group = "users";
    mode = "0644";
  };

  sops.secrets."borba_ssh_github_private_key" = {
    path = "${sshKeysDir}/id_ed25519_github";
    owner = username;
    group = "users";
    mode = "0600";
  };

  sops.secrets."borba_ssh_github_public_key" = {
    path = "${sshKeysDir}/id_ed25519_github.pub";
    owner = username;
    group = "users";
    mode = "0644";
  };

  # Dedicated GitLab / Forgejo identities are intentionally not declared yet.
  # Add their encrypted keys to each host's SOPS file first, then provision
  # them with the same pattern:
  #
  # sops.secrets."borba_ssh_gitlab_private_key" = {
  #   path = "${sshKeysDir}/id_ed25519_gitlab";
  #   owner = username;
  #   group = "users";
  #   mode = "0600";
  # };
  #
  # sops.secrets."borba_ssh_forgejo_private_key" = {
  #   path = "${sshKeysDir}/id_ed25519_forgejo";
  #   owner = username;
  #   group = "users";
  #   mode = "0600";
  # };

  # ==================== ZERO-TOUCH SSH HOST KEY BOOTSTRAP ====================
  systemd.services.ssh-hostkey-bootstrap = {
    description = "Bootstrap SSH host key into SOPS on first boot";

    wantedBy = ["multi-user.target"];
    wants = ["sshd.service"];
    before = ["sshd.service"];
    after = ["network.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    script = ''
      set -euo pipefail

      KEY="/etc/ssh/ssh_host_ed25519_key"

      if [ -f "$KEY" ]; then
        exit 0
      fi

      mkdir -p /etc/ssh

      echo "[bootstrap] generating ssh host key..."

      ssh-keygen -t ed25519 -f "$KEY" -N ""

      echo "[bootstrap] WARNING: key generated locally."

      echo "[bootstrap] you should now encrypt it with sops:"
      echo "  sops hosts/${hostname}/secrets/${hostname}.yaml"
    '';
  };
}

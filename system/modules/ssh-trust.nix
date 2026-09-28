# system/modules/ssh-trust.nix
#
# Relação de confiança SSH entre os hosts da frota, nos dois sentidos:
#
#   • Servidor: cada host aceita login do usuário borba com a chave
#     "infra" (id_ed25519_infra) dos OUTROS hosts
#     → users.users.borba.openssh.authorizedKeys.keys
#   • Cliente: cada host conhece a host key de todos os outros, então o
#     primeiro `ssh` não pergunta "trust this host?" e um MITM vira erro
#     → programs.ssh.knownHosts
#   • Nomes: <host>.infra (já coberto pelo `Host 192.168.* *.infra` em
#     system/profiles/base.nix) resolve via networking.hosts, quando o
#     IP do host está preenchido abaixo.
#
# Só entram chaves PÚBLICAS aqui (não são segredo, podem ir pro git). As
# privadas continuam no sops (borba_ssh_infra_private_key / host key).
#
# Como preencher (null = host ainda ignorado, nada quebra):
#   hostKey → no host:  cat /etc/ssh/ssh_host_ed25519_key.pub
#             (ou de fora: ssh-keyscan -t ed25519 <ip>)
#   userKey → no host:  cat ~/.ssh/id_ed25519_infra.pub
#   address → IP fixo/reserva DHCP do host na LAN
{
  lib,
  hostname,
  ...
}: let
  username = "borba"; # mesmo valor de system/profiles/base.nix

  hosts = {
    dell1564 = {
      hostKey = null; # "ssh-ed25519 AAAA..."
      userKey = null; # "ssh-ed25519 AAAA... borba@dell1564"
      address = null; # "192.168.1.x"
    };
    mac2011 = {
      hostKey = null;
      userKey = null;
      address = null;
    };
    macutm = {
      hostKey = null;
      userKey = null;
      address = null;
    };
    macvmf = {
      hostKey = null;
      userKey = null;
      address = null;
    };
    # MacBook M2 físico (macOS + home-manager, não é NixOS): não importa
    # este módulo, mas os hosts NixOS podem confiar nele / conhecê-lo.
    macbook = {
      hostKey = null;
      userKey = null;
      address = null;
    };
  };

  others = lib.filterAttrs (name: _: name != hostname) hosts;
  withHostKey = lib.filterAttrs (_: h: h.hostKey != null) hosts;
  withUserKey = lib.filterAttrs (_: h: h.userKey != null) others;
  withAddress = lib.filterAttrs (_: h: h.address != null) others;
in {
  # Quem pode entrar aqui: chave infra dos demais hosts.
  users.users.${username}.openssh.authorizedKeys.keys =
    lib.mapAttrsToList (_: h: h.userKey) withUserKey;

  # Host keys conhecidas (system-wide, /etc/ssh/ssh_known_hosts).
  programs.ssh.knownHosts =
    lib.mapAttrs (name: h: {
      hostNames =
        [name "${name}.infra"]
        ++ lib.optional (h.address != null) h.address;
      publicKey = h.hostKey;
    })
    withHostKey;

  # <host>.infra e <host> → IP (só dos outros; o próprio nome já é
  # tratado pelo NixOS via networking.hostName).
  networking.hosts =
    lib.mapAttrs' (
      name: h: lib.nameValuePair h.address [name "${name}.infra"]
    )
    withAddress;
}

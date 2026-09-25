# home/modules/herdr.nix
#
# Copiado 100% de github.com/ulyssecrn/nixos-config
# (home/modules/herdr.nix) — herdr, multiplexador de terminal com
# consciência de agente (mostra estado working/blocked/done/idle de
# cada pane, útil quando você roda vários agentes de IA em paralelo).
#
# NÃO importado em nenhum profile, e não dá pra ligar ainda: o próprio
# arquivo original já avisa que `programs.herdr` só existe no
# home-manager master, não no release-26.05 — que é exatamente o branch
# que o seu flake.nix usa (home-manager/release-26.05). Importar isso
# hoje quebraria o eval de TODOS os hosts com "option `programs.herdr`
# does not exist". Fica arquivado aqui pronto pra quando você trocar o
# input do home-manager pra unstable/master, ou o herdr chegar no
# release-26.05.
_: {
  # `herdr --remote` conecta numa sessão exec-command sem TTY, que nunca
  # lê o .zshrc — então o relink do agente precisa ficar pendurado no
  # ~/.ssh/rc, que o sshd roda em toda sessão. Seguro de assumir: desloca
  # o handling de xauth do sshd, mas dê uma olhada se você usa
  # X11Forwarding em algum host antes de ligar isso.
  home.file.".ssh/rc".text = ''
    [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] &&
      ln -sfn "$SSH_AUTH_SOCK" "$HOME/.ssh/agent.sock"
  '';

  programs.herdr = {
    enable = true;

    settings = {
      # Suprime o prompt de configuração de notificação do primeiro uso.
      # O herdr trata uma chave *ausente* como "ainda não configurado" e
      # normalmente escreveria `false` depois que você escolhesse — o que
      # ele não consegue fazer aqui, já que config.toml é um symlink
      # read-only pro store. Sem isso o prompt volta toda vez.
      onboarding = false;

      # O binário é um caminho imutável do Nix store, então `herdr
      # update` não funciona, e o polling de versão em segundo plano só
      # gera um aviso que não dá pra agir. Atualizações de versão vêm
      # pelo bump do flake mesmo.
      update = {
        version_check = false;
        manifest_check = false;
      };

      theme.name = "tokyo-night";

      ui = {
        # Toda sessão real é alcançada via SSH, então um som tocaria na
        # máquina onde você NÃO está sentado. "terminal" emite a escape
        # sequence de notificação em vez disso, que viaja de volta pela
        # conexão SSH até o cliente que estiver anexado.
        sound.enabled = false;
        toast.delivery = "terminal";

        # Ordena o sidebar por atenção necessária em vez de por
        # workspace — o ponto de rodar vários agentes ao mesmo tempo é
        # ver qual está bloqueado.
        agent_panel_sort = "priority";
      };
    };
  };
}

# home/modules/git.nix
#
# ÚNICO dono de ~/.config/git/config e do ecossistema git.
# NÃO usar programs.git.enable nem xdg.configFile."git" em NENHUM outro módulo.
{pkgs, ...}: {
  home.packages = with pkgs; [
    git
    delta
    gh
    gh-dash
    git-lfs
    git-absorb
    git-filter-repo
    lazygit
  ];

  home.file.".config/git/config".text = ''
    [user]
      name = Waldir Borba Junior
      email = wborbajr@gmail.com
      signingkey = ~/.ssh/id_ed25519.pub
    [init]
      defaultBranch = main
    [core]
      pager = delta
    [interactive]
      diffFilter = delta --color-only
    [delta]
      features = mellow-barbet
      navigate = true
    [pull]
      rebase = true
    [push]
      autoSetupRemote = true
    [branch]
      sort = -committerdate
    [checkout]
      defaultRemote = origin
    [fetch]
      prune = true
    [rerere]
      enabled = true
    [merge]
      conflictStyle = zdiff3
    [include]
      path = ~/.config/delta/themes.gitconfig
  '';

  home.file.".config/lazygit/config.yml".text = ''
    gui:
      theme:
        activeBorderColor:
          - "#cba6f7"
          - bold
        inactiveBorderColor:
          - "#a6adc8"
        optionsTextColor:
          - "#89b4fa"
        selectedLineBgColor:
          - "#313244"
        cherryPickedCommitBgColor:
          - "#45475a"
        cherryPickedCommitFgColor:
          - "#cba6f7"
        unstagedChangesColor:
          - "#f38ba8"
        defaultFgColor:
          - "#cdd6f4"
        searchingActiveBorderColor:
          - "#f9e2af"
      authorColors:
        "*": "#b4befe"
    quitOnTopLevelReturn: true
    disableStartupPopups: true
    git:
      pagers:
        - colorArg: always
          pager: delta --dark --paging=never --line-numbers --hunk-header-style="file omit-code-fragment" --file-style="omit" --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
  '';
}

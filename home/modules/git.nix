# home/modules/git.nix
#
# ÚNICO dono de ~/.config/git/config e do ecossistema git
# (lazygit → home/modules/lazygit.nix).
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
}

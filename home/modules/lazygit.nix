# home/modules/lazygit.nix
#
# LazyGit sob controle do Home Manager (programs.lazygit.settings).
# Config migrada de home/configs/lazygit/config.yaml.
#
# NÃO usar xdg.configFile."lazygit" nem home.file.".config/lazygit" noutro módulo.
_: {
  programs.lazygit = {
    enable = true;

    settings = {
      gui = {
        theme = {
          activeBorderColor = ["#cba6f7" "bold"];
          inactiveBorderColor = ["#a6adc8"];
          optionsTextColor = ["#89b4fa"];
          selectedLineBgColor = ["#313244"];
          cherryPickedCommitBgColor = ["#45475a"];
          cherryPickedCommitFgColor = ["#cba6f7"];
          unstagedChangesColor = ["#f38ba8"];
          defaultFgColor = ["#cdd6f4"];
          authorColors = [
            "#b4befe"
          ];
          searchingActiveBorderColor = ["#f9e2af"];
        };
      }; # end gui

      quitOnTopLevelReturn = true;
      disableStartupPopups = true;

      git = {
        diffRenderers = [
          {
            colorArg = "always";
            command = ''delta --dark --paging=never --line-numbers --hunk-header-style="file omit-code-fragment" --file-style="omit" --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"'';
          }
        ];
      };
    };
  };
}

# ╔════════════════════════════════════════════════════════════╗
# ║███████╗████████╗ █████╗ ██████╗ ███████╗██╗  ██╗██╗██████╗ ║
# ║██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔══██╗║
# ║███████╗   ██║   ███████║██████╔╝███████╗███████║██║██████╔╝║
# ║╚════██║   ██║   ██╔══██║██╔══██╗╚════██║██╔══██║██║██╔═══╝ ║
# ║███████║   ██║   ██║  ██║██║  ██║███████║██║  ██║██║██║     ║
# ║╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ║
# ╚════════════════════════════════════════════════════════════╝

{
  ...
}: {
  programs.starship = {
    enable = true;

    settings = builtins.fromTOML ''
      [character]
      success_symbol = "[󰁕](bold green)"
      error_symbol = "[](bold red)"
      vimcmd_symbol = "[](bold green)"

      [git_commit]
      tag_symbol = " tag "

      [git_status]
      ahead = ">"
      behind = "<"
      diverged = "<>"
      renamed = "r"
      deleted = "x"

      [aws]
      symbol = "aws "

      [azure]
      symbol = "az "

      [buf]
      symbol = "buf "

      [bun]
      symbol = "bun "

      [c]
      symbol = "C "

      [cpp]
      symbol = "C++ "

      [cobol]
      symbol = "cobol "

      [conda]
      symbol = "conda "

      [container]
      symbol = "container "

      [crystal]
      symbol = "cr "

      [cmake]
      symbol = "cmake "

      [daml]
      symbol = "daml "

      [dart]
      symbol = "dart "

      [deno]
      symbol = "deno "

      [dotnet]
      symbol = ".NET "

      [directory]
      read_only = " ro"

      [docker_context]
      symbol = "docker "

      [elixir]
      symbol = "exs "

      [elm]
      symbol = "elm "

      [fennel]
      symbol = "fnl "

      [fossil_branch]
      symbol = "fossil "

      [gcloud]
      symbol = "gcp "

      [git_branch]
      symbol = "git "

      [gleam]
      symbol = "gleam "

      [golang]
      symbol = "go "

      [gradle]
      symbol = "gradle "

      [guix_shell]
      symbol = "guix "

      [haskell]
      symbol = "haskell "

      [helm]
      symbol = "helm "

      [hg_branch]
      symbol = "hg "

      [java]
      symbol = "java "

      [julia]
      symbol = "jl "

      [kotlin]
      symbol = "kt "

      [lua]
      symbol = "lua "

      [nodejs]
      symbol = "nodejs "

      [memory_usage]
      symbol = "memory "

      [meson]
      symbol = "meson "

      [nats]
      symbol = "nats "

      [nim]
      symbol = "nim "

      [nix_shell]
      symbol = "nix "

      [ocaml]
      symbol = "ml "

      [opa]
      symbol = "opa "

      [os.symbols]
      AIX = "aix "
      Alpaquita = "alq "
      AlmaLinux = "alma "
      Alpine = "alp "
      Amazon = "amz "
      Android = "andr "
      Arch = "rch "
      Artix = "atx "
      Bluefin = "blfn "
      CachyOS = "cach "
      CentOS = "cent "
      Debian = "deb "
      DragonFly = "dfbsd "
      Emscripten = "emsc "
      EndeavourOS = "ndev "
      Fedora = "fed "
      FreeBSD = "fbsd "
      Garuda = "garu "
      Gentoo = "gent "
      HardenedBSD = "hbsd "
      Illumos = "lum "
      Kali = "kali "
      Linux = "lnx "
      Mabox = "mbox "
      Macos = "mac "
      Manjaro = "mjo "
      Mariner = "mrn "
      MidnightBSD = "mid "
      Mint = "mint "
      NetBSD = "nbsd "
      NixOS = "nix "
      Nobara = "nbra "
      OpenBSD = "obsd "
      OpenCloudOS = "ocos "
      openEuler = "oeul "
      openSUSE = "osuse "
      OracleLinux = "orac "
      Pop = "pop "
      Raspbian = "rasp "
      Redhat = "rhl "
      RedHatEnterprise = "rhel "
      RockyLinux = "rky "
      Redox = "redox "
      Solus = "sol "
      SUSE = "suse "
      Ubuntu = "ubnt "
      Ultramarine = "ultm "
      Unknown = "unk "
      Uos = "uos "
      Void = "void "
      Windows = "win "

      [package]
      symbol = "pkg "

      [perl]
      symbol = "pl "

      [php]
      symbol = "php "

      [pijul_channel]
      symbol = "pijul "

      [pixi]
      symbol = "pixi "

      [pulumi]
      symbol = "pulumi "

      [purescript]
      symbol = "purs "

      [python]
      symbol = "py "

      [quarto]
      symbol = "quarto "

      [raku]
      symbol = "raku "

      [rlang]
      symbol = "r "

      [ruby]
      symbol = "rb "

      [rust]
      symbol = "rs "

      [scala]
      symbol = "scala "

      [spack]
      symbol = "spack "

      [solidity]
      symbol = "solidity "

      [status]
      symbol = "[x](bold red) "

      [sudo]
      symbol = "sudo "

      [swift]
      symbol = "swift "

      [typst]
      symbol = "typst "

      [terraform]
      symbol = "terraform "

      [zig]
      symbol = "zig "
    '';

    # https://starship.rs/presets/gruvbox-rainbow
    # settings = {
    #   add_newline = true;
    #
    #   palette = "gruvbox_dark";
    #   palettes = {
    #     gruvbox_dark = {
    #       color_fg0    = "#fbf1c7";
    #       color_bg1    = "#3c3836";
    #       color_bg3    = "#665c54";
    #       color_blue   = "#458588";
    #       color_aqua   = "#689d6a";
    #       color_green  = "#98971a";
    #       color_orange = "#d65d0e";
    #       color_purple = "#b16286";
    #       color_red    = "#cc241d";
    #       color_yellow = "#d79921";
    #     };
    #   };
    #
    #   character = {
    #     disabled = false;
    #     success_symbol = "[󰁕](bold fg:color_green)";
    #     error_symbol = "[](bold fg:color_red)";
    #     vimcmd_symbol = "[](bold fg:color_green)";
    #     vimcmd_replace_one_symbol = "[](bold fg:color_purple)";
    #     vimcmd_replace_symbol = "[](bold fg:color_purple)";
    #     vimcmd_visual_symbol = "[](bold fg:color_yellow)";
    #   };
    #
    #   format = "[](color_orange)$os$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$cpp$rust$golang$nodejs$python$lua[](fg:color_blue bg:color_bg3)$docker_context[](fg:color_bg3 bg:color_bg1)$time[ ](fg:color_bg1)$line_break$character";
    #
    #   line_break.disabled = false;
    #
    #   time = {
    #     disabled = false;
    #     time_format = "%R";
    #     style = "bg:color_bg1";
    #     format = "[[  $time ](bold fg:color_fg0 bg:color_bg1)]($style)";
    #   };
    #
    #   directory = {
    #     style = "bold fg:color_fg0 bg:color_yellow";
    #     format = "[ $path ]($style)";
    #     truncation_length = 3;
    #     truncation_symbol = "…/";
    #
    #     substitutions = {
    #       "documents" = "󰈙 ";
    #       "downloads" = " ";
    #       "music" = "󰝚 ";
    #       "pictures" = " ";
    #       "projects" = "󰲋 ";
    #     };
    #   };
    #
    #   username = {
    #     show_always = true;
    #     style_user = "bold bg:color_orange fg:color_fg0";
    #     style_root = "bold bg:color_orange fg:color_fg0";
    #     format = "[ $user ]($style)";
    #   };
    #
    #   os = {
    #     disabled = false;
    #     style = "bold bg:color_orange fg:color_fg0";
    #     symbols = {
    #       Alpaquita = " ";
    #       Alpine = " ";
    #       AlmaLinux = " ";
    #       Amazon = " ";
    #       Android = " ";
    #       Arch = " ";
    #       Artix = " ";
    #       CentOS = " ";
    #       Debian = " ";
    #       DragonFly = " ";
    #       Emscripten = " ";
    #       EndeavourOS = " ";
    #       Fedora = " ";
    #       FreeBSD = " ";
    #       Garuda = "󰛓 ";
    #       Gentoo = " ";
    #       HardenedBSD = "󰞌 ";
    #       Illumos = "󰈸 ";
    #       Kali = " ";
    #       Linux = " ";
    #       Mabox = " ";
    #       Macos = " ";
    #       Manjaro = " ";
    #       Mariner = " ";
    #       MidnightBSD = " ";
    #       Mint = " ";
    #       NetBSD = " ";
    #       NixOS = " ";
    #       OpenBSD = "󰈺 ";
    #       openSUSE = " ";
    #       OracleLinux = "󰌷 ";
    #       Pop = " ";
    #       Raspbian = " ";
    #       Redhat = " ";
    #       RedHatEnterprise = " ";
    #       RockyLinux = " ";
    #       Redox = "󰀘 ";
    #       Solus = "󰠳 ";
    #       SUSE = " ";
    #       Ubuntu = " ";
    #       Unknown = " ";
    #       Void = " ";
    #       Windows = "󰍲 ";
    #     };
    #   };
    #
    #   aws.symbol = "  ";
    #   buf.symbol = " ";
    #
    #   c = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   cpp = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   conda.symbol = " ";
    #   crystal.symbol = " ";
    #   dart.symbol = " ";
    #
    #   docker_context = {
    #     symbol = " ";
    #     style = "bg:color_bg3";
    #     format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
    #   };
    #
    #   elixir.symbol = " ";
    #   elm.symbol = " ";
    #   fennel.symbol = " ";
    #   fossil_branch.symbol = " ";
    #   gcloud.symbol = " ";
    #
    #   git_branch = {
    #     symbol = " ";
    #     style = "bold bg:color_aqua";
    #     format = "[[ $symbol $branch ](bold fg:color_fg0 bg:color_aqua)]($style)";
    #   };
    #
    #   git_status = {
    #     style = "bold bg:color_aqua";
    #     format = "[[($all_status$ahead_behind )](bold fg:color_fg0 bg:color_aqua)]($style)";
    #   };
    #
    #   golang = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   guix_shell.symbol = " ";
    #   haskell.symbol = " ";
    #   haxe.symbol = " ";
    #   hg_branch.symbol = " ";
    #   hostname.ssh_symbol = " ";
    #   java.symbol = " ";
    #   julia.symbol = " ";
    #
    #   lua = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   memory_usage.symbol = "󰍛 ";
    #   meson.symbol = "󰔷 ";
    #   nim.symbol = "󰆥 ";
    #   nix_shell.symbol = " ";
    #
    #   nodejs = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   ocaml.symbol = " ";
    #   package.symbol = "󰏗 ";
    #   perl.symbol = " ";
    #   php.symbol = " ";
    #   pijul_channel.symbol = " ";
    #
    #   python = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   rlang.symbol = "󰟔 ";
    #   ruby.symbol = " ";
    #
    #   rust = {
    #     symbol = " ";
    #     style = "bg:color_blue";
    #     format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
    #   };
    #
    #   scala.symbol = " ";
    #   shlvl.symbol = "";
    #   swift.symbol = "󰛥 ";
    #   terraform.symbol = "󱁢";
    #   zig.symbol = " ";
    # };
  };

  # Enable catppuccin theming for starship.
  catppuccin.starship.enable = true;
}

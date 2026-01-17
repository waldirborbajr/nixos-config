{
  pkgs,
  lib,
  ...
}:

{
  ############################################
  # GPG — Global (infra)
  ############################################
  programs.gpg = {
    enable = true;

    publicKeys = [
      {
        source = ~/gpg-public.asc;
        trust = 5; # ultimate trust (sua própria chave)
      }
    ];

    mutableKeys = true;

    settings = {
      personal-cipher-preferences = "AES256";
      personal-digest-preferences = "SHA512";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 AES256 ZLIB BZIP2 ZIP Uncompressed";

      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";

      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;

      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-key-origin = true;

      require-cross-certification = true;

      # 🔐 Segurança
      no-symkey-cache = true;
      use-agent = true;
      throw-keyids = true;
    };
  };

  ############################################
  # GPG Agent — UX otimizado (sem atrito)
  ############################################
  services.gpg-agent = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;

    # Cache longo → menos prompts quando você usar GPG manualmente
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;

    enableSshSupport = true;

    pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;
  };
}

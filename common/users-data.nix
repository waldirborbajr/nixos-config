# # {
# #   borba = {
# #     fullName = "Borba Jr W";
# #     email    = "borba@email.com";
# #     gitKey   = "ABCDEF1234567890";
# #   };

# #   devops = {
# #     fullName = "DevOps User";
# #     email    = "devops@email.com";
# #     gitKey   = null;
# #   };
# # }

# {
#   # ==========================================
#   # User Identity / Profile Data
#   # ==========================================
#   # Arquivo de dados puros.
#   # NÃO deve conter lógica ou imports.
#   # Usado por:
#   # - users.nix
#   # - home-manager
#   # - git / gpg / tooling
#   # ==========================================

#   borba = {
#     fullName = "Borba Jr W";
#     email    = "borba@email.com";

#     # GPG key ID (string vazia = desativado)
#     gitKey   = "ABCDEF1234567890";
#   };

#   devops = {
#     fullName = "DevOps User";
#     email    = "devops@email.com";

#     # Usuário técnico sem assinatura GPG
#     gitKey   = "";
#   };
# }

{
  borba = {
    fullName = "Borba Jr W";
    email    = "borba@email.com";
    gitKey   = "ABCDEF1234567890";
    role     = "desktop";
  };

  devops = {
    fullName = "DevOps User";
    email    = "devops@email.com";
    gitKey   = null;
    role     = "devops";
  };
}

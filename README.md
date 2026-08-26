<p align="center">
<img alt="NixOS" src="https://raw.githubusercontent.com/NixOS/nixos-artwork/9d2cdedd73d64a068214482902adea3d02783ba8/logo/nix-snowflake-rainbow.svg" width="140px"/>
</p>
<h1 align="center">
NixOS - BORBA JR, W - Configuration
</h1>

Flake multi-host (`flake.nix` → `configuration.nix` como índice fino,
importando módulos por tópico em `modules/nixos/` → `hosts/<host>/default.nix`,
com `hosts/common/*.nix` para a família Mac), com
[Home Manager](https://github.com/nix-community/home-manager) cuidando
do usuário (`home/default.nix` + `home/configs/`) e
[sops-nix](https://github.com/Mic92/sops-nix) cuidando dos segredos por
host. Ver [`AUDIT-REPORT.md`](AUDIT-REPORT.md) para o histórico de
correções aplicadas à árvore real (bugs de duplicação, docs desalinhadas)
e [`REFACTOR-NOTES.md`](REFACTOR-NOTES.md) para o split do antigo
`configuration.nix` monolítico em `modules/nixos/`.

## 🖥️ Supported Hardware

> ⚠️ Desktop stack atual (todos os 4 hosts): **niri** (Wayland
> scrollable-tiling compositor) + **waybar** + **greetd + regreet**
> (`cage` + `regreet`, tema Catppuccin Mocha) como greeter/display manager.
> Não há i3/X11, GNOME/GDM nem `ly` em nenhum host — só a combinação acima
> (ver seções `NIRI`, `GREETD + REGREET` em `configuration.nix`).

### 🍎 MacBook Pro 13" (2011) — `mac2011`
- Architecture: x86_64
- RAM: 16 GB
- Storage: 500 GB SSD
- Role: main workstation (hardware físico)
- Desktop: niri + waybar (Wayland, via greetd/regreet)
- Wi-Fi: Broadcom BCM4331, driver open-source `b43` (o `broadcom-sta`
  proprietário está desativado — quebra ao compilar contra kernel ≥ 7.1)
- Bluetooth: `hardware.bluetooth.settings.General.ControllerMode` forçado
  para `"bredr"` (`lib.mkForce`) — o controlador Broadcom interno é BR/EDR
  clássico puro, sem LE de verdade; o default do módulo NixOS (`"dual"`)
  não bate com o hardware
- Extras só deste host: `spotify`, `chirp` (CPS de rádio), ferramentas de
  debug wireless (`iw`, `wirelesstools`) — não disponíveis/aplicáveis nas
  VMs aarch64
- Launcher: [Vicinae](https://github.com/vicinaehq/vicinae) (Raycast-like)

### 💻 Dell Inspiron 1564 — `dell1564`
- Architecture: x86_64
- RAM: 4 GB
- Storage: 120 GB SSD
- Role: basic usage / study machine
- Desktop: niri + waybar (Wayland, via greetd/regreet)
- Boot: BIOS legado + GRUB (`/dev/sda` — **não confirmado ainda**, ver
  [`TODO.md`](TODO.md)); os demais hosts usam `systemd-boot`/EFI
- Teclado: ABNT2 (`br-abnt2`)
- Wi-Fi: Broadcom BCM4312 (LP-PHY), driver open-source `b43` + firmware
  fixado em `b43Firmware_6_30_163_46` (versão específica para chips LP-PHY;
  o `wl` proprietário foi tentado e abandonado — incompatível com kernels
  recentes)
- Sem Vicinae, sem containers, sem pacotes pesados — é a máquina mais fraca
  do parque
- Nota: hostname legado da máquina física era `dell1456`; o flake usa
  `dell1564` (ver alias em `nixos-manager.sh` e em `manage-ssh-sops.sh`).
  Confirme o nome de modelo real do hardware antes de considerar um dos
  dois um typo.

### 🍏 Apple Silicon VM (UTM) — `macutm`
- Architecture: aarch64
- Role: workstation em VM (UTM), perfil `qemu-guest.nix`
- Desktop: niri + waybar (Wayland, via greetd/regreet — renderer por
  software forçado: `WLR_RENDERER=pixman`, `GSK_RENDERER=cairo`), base
  compartilhada com `macvmf` em `hosts/common/mac-vm-workstation.nix`
- Containers: `podman` com `dockerCompat = true` (só nas VMs, não no
  hardware físico)
- `boot.kernelParams = [ "mitigations=off" ]` — ganho de performance em VM

### 🍏 Apple Silicon VM (VMware Fusion) — `macvmf`
- Architecture: aarch64
- Role: workstation em VM (VMware Fusion), guest agent
  `virtualisation.vmware.guest.enable`
- Desktop: niri + waybar (Wayland, via greetd/regreet), mesma base
  compartilhada de `macutm` (`hosts/common/mac-vm-workstation.nix`)
- Containers: `podman` com `dockerCompat = true`

### 🍏 MacBook M2 (físico) — `macbook` (Home Manager standalone)
- Architecture: aarch64-darwin
- Role: instalador de apps no dia a dia — **não** é uma
  `nixosConfiguration`, é uma entrada `homeConfigurations."borba@macbook"`
  (home-manager standalone, via `mkMacHome` em `flake.nix`)
- Sem nix-darwin, sem niri/waybar/greetd — nenhuma gestão de sistema ou
  desktop, só `home-manager switch` cuidando de pacotes de usuário e
  dotfiles
- Importa só um subconjunto de `home/modules/`: `identity`, `shell`,
  `editors`, `cli-and-terminal` — **sem** `desktop.nix` (que é só pra
  niri/Wayland, não faz sentido em macOS)
- `home.packages` próprios deste host (`hosts/macbook/home.nix`): hoje só
  `darktable` — `neovim` **não** está mais aqui, foi consolidado em
  `home/modules/editors.nix` (ver seção "Módulos compartilhados" abaixo),
  já que é usado por todos os hosts, não só este
- Primeira ativação usa `home.backupFileExtension = "hm-backup"` —
  dotfile pré-existente e não gerido pelo Nix vira `<arquivo>.hm-backup`
  em vez de ser sobrescrito sem cópia
- **Pacotes das VMs (`macutm`/`macvmf`) ou de `modules/nixos/packages.nix`
  não chegam aqui** — são `nixosConfigurations` completamente separadas;
  só o que está em `home/modules/{identity,shell,editors,cli-and-terminal}.nix`
  ou direto em `hosts/macbook/home.nix` é compartilhado com este host
- Uso: `./nixos-manager.sh macbook` (ou menu `m`) — ver seção do
  `nixos-manager.sh` abaixo

### Base compartilhada da família Mac (`hosts/common/mac-workstation.nix`)

Programas, teclado (`us` + variante `mac`) e browser (Firefox Developer
Edition) usados por `mac2011`, `macutm` e `macvmf` vivem num único módulo
comum, para não repetir 3x. `dell1564` **não** importa esse módulo — segue
com sua própria lista de pacotes, mais enxuta, e Firefox estável.

---

## 🧩 Módulos compartilhados (`modules/nixos/`)

`configuration.nix` é hoje só um índice: `imports = [ ... ]` apontando pros
arquivos abaixo, aplicados a **todos** os hosts. Split puramente
estrutural do antigo `configuration.nix` monolítico — mesmo comportamento,
organizado por tópico. Detalhes de como o split foi feito e como validar
(comparação de store path antes/depois) em
[`REFACTOR-NOTES.md`](REFACTOR-NOTES.md).

| Arquivo | Conteúdo |
|---|---|
| `system-base.nix` | Kernel, tmpfiles (ssh dir + regreet), sleep policy, security/session, network, time/locale |
| `fonts.nix` | Fontes do sistema |
| `users-and-home.nix` | Shell padrão, usuário principal, wiring do Home Manager, sudo |
| `desktop-niri.nix` | niri, greetd/regreet, display manager, power-profiles-daemon, dconf, direnv, xdg portal |
| `audio.nix` | PipeWire/PulseAudio/rtkit |
| `hardware-quirks.nix` | nix-ld, bluetooth (comentários de troubleshooting preservados) |
| `packages.nix` | allowUnfree, env vars, aliases, `environment.systemPackages`, config do Nix (gc/optimise/settings) |
| `ssh.nix` | openssh (server) + `programs.ssh` (client config) |
| `sops.nix` | sops + secrets + serviço de bootstrap da host key |
| `containers-docker.nix` ⚠️ opt-in | Docker Engine (`enableOnBoot = false`, socket-activated) + grupo `docker` + `docker-compose` — import comentado, veja seção "Containers / Kubernetes" abaixo |
| `containers-podman.nix` ⚠️ opt-in | Podman rootless + `dockerCompat` (ganha o comando `docker`) + `podman-compose`/`lazydocker` — import comentado |
| `kubernetes-dev.nix` ⚠️ opt-in | `k3d` + `kubectl` + `k9s` (cluster local leve, sem systemd) — import comentado, precisa de um dos dois acima ligado junto |

Pra editar algo, vá direto no arquivo do tópico — não precisa mais
navegar um `configuration.nix` de 500+ linhas pra achar uma seção.

---

## 🐳 Containers / Kubernetes (opt-in, desligado por padrão)

Docker, Podman e Kubernetes local são usados só em projetos específicos,
não no dia a dia — por isso os 3 módulos existem no repo mas ficam **com
o import comentado** em `configuration.nix`. Pra usar:

```bash
# configuration.nix — descomente a(s) linha(s) relevante(s):
# ./modules/nixos/containers-docker.nix
# ./modules/nixos/containers-podman.nix
# ./modules/nixos/kubernetes-dev.nix
```

depois rode o rebuild normal (`./nixos-manager.sh flake` ou `build`).
Quando não precisar mais, comente de novo e rebuild — nenhum dos três
deixa serviço rodando à toa nesse estado desligado.

| Módulo | O que dá | Footprint quando ligado mas sem uso |
|---|---|---|
| `containers-docker.nix` | Docker Engine + `docker-compose` | Zero — `enableOnBoot = false`, o daemon só sobe ao tocar o socket (`docker ps` etc.); depois de subir, fica rodando até `systemctl stop docker` ou reboot |
| `containers-podman.nix` | Podman rootless + `dockerCompat` (alias `docker`) + `podman-compose`/`lazydocker` | Zero sempre — sem daemon, é fork-per-comando |
| `kubernetes-dev.nix` | `k3d` + `kubectl` + `k9s` | Zero — são só binários, sem serviço systemd; o cluster só existe entre `k3d cluster create` e `k3d cluster delete` |

> **`k9s` sozinho não sobe cluster nenhum** — é só um dashboard/TUI pra um
> cluster que já existe (via kubeconfig), local ou remoto. Pra ter
> cluster local de verdade, `kubernetes-dev.nix` inclui `k3d` também: ele
> cria um cluster k3s efêmero rodando como containers, em cima do runtime
> que você já tiver ligado (`containers-docker.nix` ou
> `containers-podman.nix` — precisa de um dos dois, é ele quem cria os
> nodes do cluster).
>
> `containers-docker.nix` e `containers-podman.nix` são independentes:
> dá pra ligar só um, ou os dois juntos sem conflito.
>
> A família Mac (`hosts/common/mac-workstation.nix`) já tem um pacote
> `podman` cru (+ `lazydocker`) pra uso básico rootless, sem passar por
> `containers-podman.nix`. Ligar `containers-podman.nix` num host Mac não
> quebra nada (Nix deduplica o pacote) — só passa a ligar o
> `dockerCompat`/rede default que o pacote cru sozinho não configura.

---

## 🚀 Recreating a host from scratch (order matters)

This section is for anyone (including future-you) who clones this repo onto
a brand-new machine and needs to know **exactly** what to run, and in what
order. Skipping a step or running them out of order is the most common
cause of a failed first `nixos-rebuild switch`.

### Why the order matters

This flake uses [SOPS](https://github.com/getsops/sops) (via
[sops-nix](https://github.com/Mic92/sops-nix)) to encrypt SSH keys
(`hosts/<host>/secrets/<host>.yaml`). `nixos-rebuild switch` decrypts that
file during activation using a local [age](https://github.com/FiloSottile/age)
key at `~/.config/sops/age/keys.txt` (`sops.age.keyFile` in
`configuration.nix` — per-user, not `/etc`) — but on a **genuinely fresh**
machine, neither that age key nor the encrypted secrets file exist yet, and
the tools needed to create them (`sops`, `age`, `jq`) only get installed
*by* a successful rebuild. That's a chicken-and-egg problem, and it's
exactly what breaks if you jump straight to step 4 below.

> ⚠️ `~/.config/sops/age/keys.txt` is the **only** thing that can decrypt
> that host's secrets — it's intentionally never committed (see
> `.gitignore`). If the disk is wiped without a backup of this file, every
> secret encrypted for that host becomes permanently unrecoverable, even
> though the encrypted `.yaml` survives fine in git. Back it up with
> `./scripts/backup-age-key.sh` (prints the key + its public fingerprint,
> never writes to disk or network) right after step 3 below, and store it
> in a password manager.

The steps must run in this order:

**1. Install base NixOS** (via the official ISO / installer), with flakes
   enabled. At this point you just need a working system with `git`,
   `openssh`, and internet access — the full flake config isn't applied yet.

**2. Clone this repo** to the fixed path every host expects:
   ```bash
   git clone git@github.com:waldirborbajr/nixos-config.git ~/nixos-config
   ```
   (If you don't have an SSH key registered with GitHub yet on this fresh
   machine, clone via HTTPS first — `https://github.com/waldirborbajr/nixos-config.git`
   — you can switch the remote to SSH later once your GitHub key exists,
   which happens in step 3.)

**3. Bootstrap SSH keys + SOPS secrets — BEFORE the first real rebuild.**
   The tools this needs (`sops`, `age-keygen`, `jq`, `ssh-keygen`) aren't
   installed by the system yet, so run them from a temporary ad-hoc shell:
   ```bash
   cd ~/nixos-config
   nix shell nixpkgs#sops nixpkgs#age nixpkgs#jq nixpkgs#openssh
   ./scripts/manage-ssh-sops.sh <host> --clean
   ```
   Replace `<host>` with one of: `dell1564`, `mac2011`, `macutm` (aliases
   like `dell`, `mac`, `m2utm` also work — see the script header).

   Always use `--clean` the **first** time you set up a host — it builds a
   correct, complete encrypted YAML from scratch. Without `--clean`, the
   script does incremental `sops set` updates on an existing file, which
   assumes the file is already in a valid state.

   This step generates and encrypts:
   - `borba_ssh_infra_private_key` / `_public_key` — SSH identity for
     server-to-server access
   - `borba_ssh_github_private_key` / `_public_key` — SSH identity for
     GitHub/GitLab/Forgejo
   - `ssh_host_ed25519_key` — this machine's own SSH host key

   Commit and push the resulting `hosts/<host>/secrets/<host>.yaml` (it's
   encrypted — safe to commit, contains no plaintext):
   ```bash
   git add hosts/<host>/secrets/<host>.yaml
   git commit -m "secrets: bootstrap <host>"
   git push origin main
   ```

**4. Point `/etc/nixos` at the repo and run the real rebuild:**
   ```bash
   ./nixos-manager.sh setup      # symlinks /etc/nixos -> ~/nixos-config
   ./nixos-manager.sh flake      # select branch + host, then rebuild
   ```
   Note: `nixos-manager.sh`, `tmux-devshell.sh` and `zellij-devshell.sh`
   live at the **repo root**, not under `scripts/` — only
   `manage-ssh-sops.sh` and `backup-age-key.sh` live in `scripts/`. The two
   devshell launchers are also installed as commands
   (`tmux-devshell`/`zellij-devshell` in `~/.local/bin`, see the section
   below) so they work from inside any project, not just the repo root.

   This is the first rebuild that can actually succeed, because the age key
   and encrypted secrets from step 3 already exist on disk. From here on,
   `sops`/`age`/`jq` are installed system-wide, Home Manager takes over the
   user environment, and dotfiles for zsh, git, helix, tmux, niri, waybar,
   wezterm, zellij, bat, btop, lazygit, atuin, oh-my-posh, ripgrep, and
   wlr-which-key are applied automatically from `home/configs/` — either
   via native `programs.*` modules or `xdg.configFile` (see
   `home/default.nix`). No external `~/dotfiles` repo and no manual `stow`
   are needed anymore.

**5. Back up the age key** (do this once, right after step 3):
   ```bash
   ./scripts/backup-age-key.sh
   ```
   Prints the key and its public fingerprint so you can paste it into a
   password manager. Never commit this output anywhere.

**6. Re-running the SSH/SOPS script later** (e.g. adding a new key,
   rotating an existing one) uses the same script *without* `--clean`:
   ```bash
   ./scripts/manage-ssh-sops.sh <host>
   ```
   This updates individual keys via `sops set`, preserving any other
   secret already present in the file — safe to re-run anytime.

### Quick reference

| Step | Command | Requires |
|---|---|---|
| 1 | Install base NixOS | — |
| 2 | `git clone ... ~/nixos-config` | git |
| 3 | `nix shell nixpkgs#sops nixpkgs#age nixpkgs#jq nixpkgs#openssh` then `./scripts/manage-ssh-sops.sh <host> --clean` | ad-hoc `nix shell` |
| 3b | `git add/commit/push` the encrypted secrets file | git |
| 4 | `./nixos-manager.sh setup` then `flake` | steps 1–3 done |
| 5 | `./scripts/backup-age-key.sh` — save output in a password manager | age key exists (step 3) |
| 6+ | `./scripts/manage-ssh-sops.sh <host>` (no `--clean`) | system already built |

---

## 🧰 `nixos-manager.sh` — rebuilds, cache, and updates

Menu interativo (ou modo direto por argumento) para as tarefas do dia a dia
de manutenção do flake: rebuild, limpeza de cache, updates, rollback,
checagem do flake e gestão de branches. Vive na **raiz do repo**
(`./nixos-manager.sh`) e assume um repo git em `$NIXOS_DIR` (por padrão, a
pasta onde o próprio script está).

### Uso

```bash
./nixos-manager.sh                    # abre o menu interativo
./nixos-manager.sh <option>           # roda direto: legacy | flake | clean | update | generation
./nixos-manager.sh <option> <host>    # roda direto num host específico: flake dell
NIXOS_FLAKE_ATTR=dell ./nixos-manager.sh flake   # força o host via env var
```

### Opções do menu

| # | Palavra-chave | Ação |
|---|---|---|
| 0 | `setup` | Setup inicial numa máquina nova (symlink `/etc/nixos` → repo, clone se necessário, detecta o host) |
| 1 | `legacy` | Build sem flake (`nixos-rebuild switch`, usa `/etc/nixos` via symlink) |
| 2 | `flake` | Build com flake — fluxo completo: seleciona branch → checkout → commit pendente → pull → rebuild → push |
| 3 | `clean` | Limpa cache: modo *Quick* (gerações >14 dias) ou *Aggressive* (`nix-collect-garbage -d`), com sync do bootloader ao final |
| 4 | `update` | Update do sistema (mesmo fluxo git do `flake`, mais `nix flake update`) |
| 5 | `dry` | Test build (dry-run, não aplica nada) |
| 6 | `rollback` | Rollback para a geração anterior (`nixos-rebuild switch --rollback`) |
| 7 | `check` | `nix flake check --print-build-logs`, opcionalmente para um host específico |
| 8 | `hosts` | Lista os hosts configurados no flake e qual bate com esta máquina |
| 9 | `branches` | Lista branches locais + remotas, marcando a atual e as sem correspondência na origin |
| a | `prune` | Remove branches locais que não têm mais par na `origin` (branch padrão e a atual nunca são candidatas) |
| g | `generation` | Mostra a última geração do sistema (perfil Nix + entradas do bootloader) |
| m | `home` / `macbook` | **Só no MacBook M2 físico**: `home-manager switch --flake ".#borba@macbook"` — standalone, não é `nixos-rebuild` (sem sudo, sem bootloader, sem geração de sistema) |
| c | `cleanmac` / `macclean` | **Só no MacBook M2 físico**: limpeza de gerações do home-manager (`nix-collect-garbage`, Quick/Aggressive) + otimização do store — equivalente ao `clean` (3), mas sem sudo e sem sync de bootloader |
| q | `quit` | Sai |

### Hosts conhecidos (flake attr → hostname real)

| Flake attr | Hostname | Label |
|---|---|---|
| `macbook2011` | `mac2011` | MacBook Pro 13in (2011) |
| `dell` | `dell1564` (alias legado: `dell1456`) | Dell Inspiron 1564 |
| `m2utm` | `macutm` | MacBook M2 - UTM |
| `macvmf` | `macvmf` | MacBook M2 - VMware Fusion |

> ⚠️ `macbook` (MacBook M2 físico) **não** está nesta tabela — ele não é
> uma `nixosConfiguration`, então não tem "flake attr" nesse sentido.
> As opções `m`/`c` chamam direto `homeConfigurations."borba@macbook"`
> e não passam pelo fluxo de detecção/seleção de host usado por `flake`,
> `update`, `dry` etc.

### Comportamento importante

- **Host nunca é assumido**: se não vier por argumento nem por
  `NIXOS_FLAKE_ATTR`, o script sempre pergunta — mesmo que a máquina atual
  bata com um host conhecido via `hostname`, ele não usa isso como default
  (evita rebuild no host errado quando o comando roda remotamente, ex. via
  SSH de outra máquina).
- **Branch também nunca é assumida** quando há mais de uma disponível: se
  só existir a branch padrão (`main`), o script segue direto sem perguntar;
  havendo outras branches (locais ou remotas), ele sempre pergunta qual usar
  — em todo `flake`/`update`, nunca só na primeira vez.
- **Dell (baixa RAM)**: builds forçadamente seriais para evitar OOM killer,
  via flags extras aplicadas por `rebuild_extra_flags()`.
- **Clean cache** sempre oferece sincronizar o bootloader (`nixos-rebuild
  boot`) depois de remover gerações antigas — sem isso, o menu de boot
  continua listando entradas para gerações que não existem mais.

---

## 🪟 `tmux-devshell` / `zellij-devshell` — profiles de devshell em qualquer projeto

Abrem uma sessão (tmux ou Zellij, mesmo profile system nos dois) com uma
window/tab por devshell Nix, a partir de um profile pré-definido (combo de
devshells) ou de uma seleção manual (custom).

Os scripts-fonte vivem na **raiz do repo** (`./tmux-devshell.sh`,
`./zellij-devshell.sh`), mas também são **instalados como comando**
(`~/.local/bin/tmux-devshell`, `~/.local/bin/zellij-devshell` — via
`home/modules/cli-and-terminal.nix`, `$HOME/.local/bin` já está no `PATH`
por `home/configs/zshenv`). Rode de dentro de **qualquer projeto** em
`$HOME/prj/<algo>` — não precisa estar no nixos-config nem passar
caminho nenhum:

```bash
cd ~/prj/minha-api
tmux-devshell rust+postgres      # ou: zellij-devshell rust+postgres
```

Os devshells continuam vindo do nixos-config (localizado via
`NIXOS_CONFIG_DIR`, default `$HOME/nixos-config`), mas o `cwd` de cada
window/tab é o projeto de onde você chamou o comando — é lá que o
`cargo build`/`go build`/etc. realmente roda.

### Uso

```bash
tmux-devshell                # menu interativo, a partir do projeto atual
tmux-devshell --clean        # mata a sessão existente antes de criar uma nova
tmux-devshell go+maria       # pula o menu, usa o profile direto

zellij-devshell                # idem, via Zellij
zellij-devshell --clean
zellij-devshell go+maria
```

### Profiles pré-definidos

| Profile | Devshells |
|---|---|
| `go+maria` | go, mariadb |
| `go+postgres` | go, postgresql |
| `rust+postgres` | rust, postgresql |
| `rust+maria` | rust, mariadb |
| `lua+sqlite` | lua, sqlite |
| `python+mongo` | python, mongodb |
| `fullstack` | go, rust, postgresql, mariadb |

Além dos profiles, a opção **custom** no menu permite selecionar
manualmente qualquer combinação das pastas existentes em `devshells/`
(incluindo `arduino` e `latex`, que não entram em nenhum profile
pré-definido, e `rust+sqlite`/`go+sqlite`, que ainda não têm profile
dedicado — só via custom).

> `go`/`rust`/`python` são shells **puras de linguagem** (sem
> Postgres/MariaDB/SQLite embutido) — quem entra no jogo é o profile
> (ou a seleção custom), combinando a linguagem com o banco que você
> quiser naquele projeto. Exceção: se algum projeto usa uma crate/lib
> que **linka** contra a lib nativa do banco em tempo de build (ex:
> `sqlx`/`diesel` sem feature `bundled`), abrir o banco numa tab separada
> não basta — a lib precisa estar no mesmo shell do build.

### Requisitos e fallback

- **`fzf`** (opcional, recomendado): habilita o seletor visual, tanto para
  escolher o profile quanto para a seleção custom de devshells, com preview
  mostrando quais devshells cada profile inclui.
- **Sem `fzf`**: cai automaticamente para um menu numerado no terminal —
  nenhuma funcionalidade é perdida, só a experiência de seleção muda.
- **`tmux-devshell`**: precisa de `tmux`.
- **`zellij-devshell`**: precisa de `zellij`. Cada tab nasce com
  `default_tab_template` (tab-bar + status-bar), igual ao layout `default`
  de fábrica do Zellij — sem isso as tabs aparecem "nuas", sem barra
  nenhuma.

### Variáveis de ambiente

| Variável | Padrão | Descrição |
|---|---|---|
| `NIXOS_CONFIG_DIR` | `$HOME/nixos-config` | Onde fica o nixos-config, pra achar `devshells/` |
| `DEVSHELLS_DIR` | `$NIXOS_CONFIG_DIR/devshells` | Pasta com as subpastas de cada devshell |
| `PROJECT_DIR` | `$(pwd)` no momento em que o comando é chamado | Vira o `cwd` real de cada window/tab — normalmente o projeto em `$HOME/prj/<algo>` |
| `SESSION_PREFIX` | `dev` | Prefixo do nome da sessão (ex: `dev-minha-api-go+maria` — inclui o nome do projeto, pra não colidir entre projetos diferentes usando o mesmo profile) |

---

## 🛠️ Development Shells

Development environments are organized in dedicated folders under [devshells](devshells), each with its own flake. You can enter them directly from the repository without changing the main flake configuration, or use `tmux-devshell`/`zellij-devshell` (acima) to open several at once from inside any project directory.

### Available environments

```bash
# Go (pure — combine with a db devshell via tmux-devshell/zellij-devshell profiles)
nix develop ./devshells/go

# Rust (pure — combine with a db devshell via tmux-devshell/zellij-devshell profiles)
nix develop ./devshells/rust

# Lua
nix develop ./devshells/lua

# Python (uv2nix)
nix develop ./devshells/python

# Arduino
nix develop ./devshells/arduino

# LaTeX
nix develop ./devshells/latex

# PostgreSQL (server + psql/pgcli)
nix develop ./devshells/postgresql

# MariaDB (server + mycli)
nix develop ./devshells/mariadb

# SQLite (sqlite3 + analyzer + docs)
nix develop ./devshells/sqlite

# MongoDB
nix develop ./devshells/mongodb
```

### Usage notes

- Each folder contains its own [flake.nix](flake.nix) style definition for that toolchain or database.
- The shell name is usually the same as the folder name, so `nix develop ./devshells/go` works as expected.
- `go`/`rust`/`python` are language-only shells — no database tooling baked in. Combine with a db devshell (`postgresql`, `mariadb`, `sqlite`, `mongodb`) via a `tmux-devshell`/`zellij-devshell` profile, or run both `nix develop` shells side by side manually.
- This keeps each environment isolated and easier to maintain.

**Advantages:**
- ✅ Isolated environments per stack
- ✅ Specific tool versions per language/database
- ✅ Reproducible across machines
- ✅ No need to modify the main flake for day-to-day use

---

## ⌨️ Logitech K380 Bluetooth pairing (Linux)

`logitech-k380-bluetooth-linux-fix/` guarda um script `expect` standalone
(fora do flake, roda em qualquer distro com `bluetoothctl`/`bluez`) para
contornar o pareamento do teclado K380: o `bluetoothctl` padrão mostra o
PIN por pouco tempo (~10s) e o K380 precisa de mais tempo para digitar o
código.

```bash
cd logitech-k380-bluetooth-linux-fix
chmod +x pair_k380.exp
./pair_k380.exp        # captura e exibe o PIN, dá 60s para digitar no teclado
```

Requer `expect` + `bluez` instalados (`bluetooth`/`bluez` no host). Ver
`pair_k380_auto.exp` para uma variante não-interativa, e o
[README próprio](logitech-k380-bluetooth-linux-fix/README.md) para
troubleshooting (reset do teclado, reconexão manual via
`bluetoothctl connect <MAC>`).

> Este fix trata do handshake de pareamento em si. Para o comportamento
> específico do controlador Bluetooth do `mac2011` (Broadcom BR/EDR
> clássico) dentro do NixOS, ver `hardware.bluetooth.settings.General.
> ControllerMode = lib.mkForce "bredr"` em `hosts/mac2011/default.nix`.

---

## 📚 Other docs in this repo

- [`DENDRITIC-PATTERN.md`](DENDRITIC-PATTERN.md) — **aspiracional, não
  implementado.** Descreve uma arquitetura-alvo (`core.nix`, `profiles/`,
  `modules/category/default.nix`) que não existe nesta árvore hoje; mantido
  só como referência de design para uma eventual refatoração futura.
- [`scripts/age-key-backup-e-restauracao.md`](scripts/age-key-backup-e-restauracao.md)
  — passo a passo de backup/restauração da chave age (complementa
  `scripts/backup-age-key.sh`).

---

```text
https://git.voidarc.co.uk/voidarc/nixos
```

git pull origin m2config
# sudo nixos-rebuild switch
git add -A
git commit -m "lock: update"
git push origin m2config
sudo nixos-rebuild switch --flake .#nixos

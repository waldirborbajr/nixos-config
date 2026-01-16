git pull
git add .
git commit -m "wip" 
git push
sudo nixos-rebuild switch --flake .#dell --impure
# make flake-update
# make nixos-rebuild HOST=dell
